/* Copyright (C) 2017 BMW Group
 * Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
 * based on the work of Klaus Birken (itemis AG)
 * 
 * This Source Code Form is subject to the terms of the Eclipse Public
 * License, v. 1.0. If a copy of the EPL was not distributed with this
 * file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */
package org.franca.compmodel.dsl.ui.contentassist

import com.google.common.base.Joiner
import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.jdt.internal.core.JavaProject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.RuleCall
import org.eclipse.xtext.resource.IContainer
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.ResourceDescriptionsProvider
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier
import org.franca.compmodel.dsl.fcomp.FCAnnotationType
import org.franca.compmodel.dsl.fcomp.FCModel
import org.franca.compmodel.dsl.fcomp.FCTagDecl
import org.franca.compmodel.dsl.fcomp.Import
import org.franca.core.utils.FrancaIDLUtils
import java.util.ArrayList

class FCompProposalProvider extends AbstractFCompProposalProvider {
	
	protected final static String[] extensionsForImportURIScope = #[ "fidl", "fcdl" ]

	@Inject
	private IResourceDescription.Manager descriptionManager;
	@Inject
	private IContainer.Manager containerManager;
	@Inject
	private ResourceDescriptionsProvider provider;

	public override completeImport_ImportURI(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		var FCModel fcmodel = null
		val modelUri = model.eResource.URI
		if(model instanceof FCModel) 
			fcmodel = model
		else if(model instanceof Import)
			fcmodel = model.eContainer as FCModel
		
		val importedUris = fcmodel.imports.map[it.importURI]
		val platformResources = new ArrayList<URI>()
		val classpathResources = new ArrayList<URI>()
		var xtextresourceSet = model.eResource.resourceSet as XtextResourceSet
		var containers = containerManager.getVisibleContainers(
			descriptionManager.getResourceDescription(model.eResource),
			provider.getResourceDescriptions(model.eResource))

		val classPathContext = xtextresourceSet.classpathURIContext
		
		containers.forEach [
			it.resourceDescriptions.filter[
				it.URI.toString != model.eResource.URI.toString && 
					extensionsForImportURIScope.contains(it.URI.fileExtension)].forEach [
				platformResources += it.URI
				if (classPathContext instanceof JavaProject) 
					classpathResources += it.URI
			]
		]
		

		if (context.prefix.contains("classpath:")) {
			classpathResources.forEach [
				it.createClasspathProposal(modelUri,context, acceptor,importedUris)
			]
		} else {
			platformResources.forEach [
				it.createFilenameProposal(modelUri,context,acceptor,importedUris)
			]
		}
		super.completeImport_ImportURI(model, assignment, context, acceptor)
	}
	
	def void createClasspathProposal(URI uri,URI model, ContentAssistContext context, ICompletionProposalAcceptor acceptor,List<String> importedUris)
	{
		var result = toClassPathString(uri);
		if(!importedUris.contains(result)){
			var displayString = uri.lastSegment() + " - " + result;
			createProposal(result,displayString, context, acceptor);
		}
	}
	
	def void createFilenameProposal(URI uri,URI model, ContentAssistContext context, ICompletionProposalAcceptor acceptor,List<String> importedUris)
	{
		val result = FrancaIDLUtils.relativeURIString(model,uri)
		if(!importedUris.contains(result)){
			var displayString = uri.lastSegment() + " - " + result;
			createProposal(result,displayString,context,acceptor)
		}
	}
	
	def toClassPathString(URI uri) {
		val segments = uri.segmentsList.classPathSegments
		'classpath:/' + Joiner.on('/').join(segments) + ''.toString

	}

	def classPathSegments(List<String> list) {
		var sublist = list.subList(3, list.size)
		sublist
	} 

	def createProposal(String name, String display, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var proposal = createCompletionProposal(name.toString,display,null, context)

		if (proposal instanceof ConfigurableCompletionProposal) {
			proposal.textApplier = new ReplacementTextApplier() {
				override getActualReplacementString(ConfigurableCompletionProposal proposal) {
					proposal.replacementLength = proposal.replaceContextLength
					'"' + name.toString + '"\r\n'
				}
			}
		}
		acceptor.accept(proposal)
	}
	
	/** Avoid generic proposal "importURI". */
	override public void complete_STRING(EObject model, RuleCall ruleCall,
			ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		var Assignment ass = GrammarUtil.containingAssignment(ruleCall);
		if (ass === null || !"importURI".equals(ass.getFeature())) {
			super.complete_STRING(model, ruleCall, context, acceptor);
		}
	}
	
	/** Combine proposals for custom annotation tags with default built-in annotations */
	public override complete_FCAnnotation(EObject model, RuleCall ruleCall, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		val tagDecls = model.eResource.resourceSet.allContents.filter(FCTagDecl).toList
		for (tag: tagDecls ) {
			val text = tag.name
			val proposal = createCompletionProposal(text, text, null, context)
			acceptor.accept(proposal)
		}
		
		for (annoType: FCAnnotationType.VALUES ) {
			if (annoType != FCAnnotationType.CUSTOM_VALUE) {
				val proposal = createCompletionProposal(annoType.literal, annoType.literal, null, context)
				acceptor.accept(proposal)
			}
		}
		
		super.complete_FCAnnotation(model, ruleCall, context, acceptor)
	}
}
