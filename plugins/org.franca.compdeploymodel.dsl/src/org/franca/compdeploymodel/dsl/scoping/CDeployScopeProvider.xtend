package org.franca.compdeploymodel.dsl.scoping

import com.google.inject.Inject
import java.util.ArrayList
import java.util.List
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.franca.compdeploymodel.dsl.cDeploy.FDComAdapter
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.compdeploymodel.dsl.cDeploy.FDComponentInstance
import org.franca.compdeploymodel.dsl.cDeploy.FDDevice
import org.franca.compdeploymodel.dsl.cDeploy.FDProvidedPort
import org.franca.compdeploymodel.dsl.cDeploy.FDRequiredPort
import org.franca.compdeploymodel.dsl.cDeploy.FDService
import org.franca.compdeploymodel.dsl.cDeploy.FDVariant
import org.franca.compmodel.dsl.FCompUtils
import org.franca.compmodel.dsl.fcomp.FCComponent
import org.franca.compmodel.dsl.fcomp.FCGenericPrototype
import org.franca.compmodel.dsl.fcomp.FCPort
import org.franca.compmodel.dsl.fcomp.FCPortKind
import org.franca.core.franca.FInterface
import org.franca.deploymodel.core.PropertyMappings
import org.franca.deploymodel.dsl.fDeploy.FDElement
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDRootElement
import org.franca.deploymodel.dsl.fDeploy.FDSpecification

import static org.franca.deploymodel.core.FDModelUtils.*

import static extension org.eclipse.xtext.scoping.Scopes.*
import static extension org.franca.core.FrancaModelExtensions.*

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CDeployScopeProvider extends AbstractCDeployScopeProvider {

	@Inject IQualifiedNameConverter qnConverter;

	// *****************************************************************************

	def scope_FDProperty_decl(FDService owner, EReference ref) {
		owner.getPropertyDecls
	}
		
	def scope_FDProperty_decl(FDDevice owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDComAdapter owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDVariant owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDRequiredPort owner, EReference ref) {
		owner.getPropertyDecls
	}
	
	def scope_FDProperty_decl(FDProvidedPort owner, EReference ref) {
		owner.getPropertyDecls
	}

	def private IScope getPropertyDecls(FDElement elem) {
		val root = getRootElement(elem)
		val spec = root.actualSpec

		if (spec !== null)
			PropertyMappings::getAllPropertyDecls(spec, elem).scopeFor
		else
			IScope::NULLSCOPE
	}

	/**
	 * Get the deployment specification for a definition root element.</p>
	 * 
	 * In standard Franca deployment, each root element will have its own root.
	 * However, in CDeploy, nested root elements might be defined. If a nested
	 * root element doesn't have its own spec, it will use its parent's spec.
	 */
	def private FDSpecification getActualSpec(FDRootElement elem) {
		if (elem.spec!==null)
			elem.spec
		else
			getRootElement(elem.eContainer as FDElement)?.spec
	}


	// *****************************************************************************

	/**
	 * Component Instance starting point scoping: limit to root components
	 */
	def IScope scope_FDComponentInstance_target(FDService service, EReference ref) {
		
		val List<IEObjectDescription> rootComponents = <IEObjectDescription>newArrayList
		for (od: delegateGetScope(service, ref).allElements) {
			val comp = od.EObjectOrProxy
			if (comp instanceof FCComponent) {
				if (comp.root)
					rootComponents.add(new EObjectDescription(qnConverter.toQualifiedName(comp.name), comp, null))
			}
		}
		val scope = new SimpleScope(rootComponents)
		// dump(scope, "scope_FDComponentInstance_target")
		scope
	}

	/**
	 * Component Instance segments scoping
	 * Path contains only non-abstract components
	 */
    def IScope scope_FDComponentInstance_prototype(FDComponentInstance compInst, EReference ref) {
		val parent = compInst.parent
		if(parent === null)
			return IScope.NULLSCOPE
			
		var ArrayList<FCGenericPrototype> candidates = newArrayList()
		if (parent.prototype === null && parent.target !== null) {
			FCompUtils.collectInheritedPrototypes(parent.target, candidates)
		} 
		else {
			FCompUtils.collectInheritedPrototypes(parent.prototype.component, candidates)
		} 
		val scope = candidates.filter[component.abstract == false].scopeFor	
		// dump(scope, "scope_FDComponentInstance_prototype")
		scope
	}

	/**
	 * Limit scope to service for use on a device
	 */
	def IScope scope_FDRootElement_use(FDDevice device, EReference ref) {

		val IScope delegateScope = delegateGetScope(device, ref)
		new FilteringScope(delegateScope, [EObjectOrProxy instanceof FDService])
	}
	
	/**
	 * Limit scope to adapter defined for the given device 
	 */
	def IScope scope_FDComAdapter_target(FDDevice device, EReference ref) {
		if (device.adapters !== null) {
			val scope = device.target.adapters.scopeFor
			return scope
		}
		IScope::NULLSCOPE
	}
	
	/**
	 * Limit scope to devices with services matching the given root in the context of a variant
	 */
	def IScope scope_FDRootElement_use(FDVariant variant, EReference ref) {

		val IScope delegateScope = delegateGetScope(variant, ref)
		new FilteringScope(delegateScope, [EObjectOrProxy instanceof FDDevice])
	}
	
	/**
	 * Scope roots in the context of a variant
	 */
	def IScope scope_FDVariant_root(FDVariant variant, EReference ref) {

		val List<IEObjectDescription> rootComponents = <IEObjectDescription>newArrayList
		for (od: delegateGetScope(variant, ref).allElements) {
			val comp = od.EObjectOrProxy
			if (comp instanceof FCComponent) {
				if (comp.root)
					rootComponents.add(new EObjectDescription(qnConverter.toQualifiedName(comp.name), comp, null))
			}
		}
		val scope = new SimpleScope(rootComponents)
		// dump(scope, "scope_FDComponentInstance_target")
		scope
	}
	
	
	/**
	 * Limit scope to provided ports defined for used services the context of an adapter of a device
	 */
	def IScope scope_FDRootElement_use(FDComAdapter adapter, EReference ref) {
		val device = adapter.eContainer
		if (device instanceof FDDevice) {
			val pPorts = device.use.filter(FDService).map[providedPorts].flatten
			val rPorts = device.use.filter(FDService).map[requiredPorts].flatten
			val IScope delegateScope = delegateGetScope(adapter, ref)
			new FilteringScope(delegateScope, [
				val port = it.EObjectOrProxy
				switch (port) {
					FDProvidedPort: pPorts.exists[it==port && haveCompatibleSpecs(adapter, port, [actualSpec])]
					FDRequiredPort: rPorts.exists[it==port && haveCompatibleSpecs(adapter, port, [actualSpec])]
					default: false
				}
			])
		}
		else
			IScope::NULLSCOPE
	}
	
	
	/**
	 * Limit scope for component to compatible components deployments in a service context
	 */
	def IScope scope_FDRootElement_use(FDService service, EReference ref) {
		val componentType = service.target.prototype?.component ?: service.target.target
		val IScope delegateScope = delegateGetScope(service, ref)
		new FilteringScope(delegateScope, [
			val obj = it.EObjectOrProxy
			if (obj instanceof FDComponent)
				obj.target==componentType
			else
				false
		])
	}	
	
	/**
	 * Limit scope to components deployments in a component context
	 */
	def IScope scope_FDRootElement_use(FDComponent component, EReference ref) {
		val IScope delegateScope = delegateGetScope(component, ref)
		new FilteringScope(delegateScope, [EObjectOrProxy instanceof FDComponent])
	}
	
	
	/**
	 * Scope available interface deployments in required port deployment to fitting interfaces
	 */
	def IScope scope_FDRootElement_use(FDRequiredPort port, EReference ref) {
		val FInterface interfaceType = port.target.interface
		val IScope delegateScope = delegateGetScope(port, ref)
		filterInterfaceForPort(port, delegateScope, interfaceType)	
	}
	
	/**
	 * Scope available interface deployments in provided port deployment to fitting interfaces
	 */
	def IScope scope_FDRootElement_use(FDProvidedPort port, EReference ref) {
		val FInterface interfaceType = port.target.interface
		val IScope delegateScope = delegateGetScope(port, ref)
		filterInterfaceForPort(port, delegateScope, interfaceType)
	}
	
	private def IScope filterInterfaceForPort(FDRootElement port, IScope delegateScope, FInterface interfaceType) {
		val inheritedInterfaces = interfaceType.interfaceInheritationSet
		new FilteringScope(delegateScope, [
			val obj = it.EObjectOrProxy
			if (obj instanceof FDInterface) {
				inheritedInterfaces.contains(obj.target) && haveCompatibleSpecs(port, obj, [actualSpec]) 
			} else 
				false
		])
	}

	// *****************************************************************************
	// ports in scope of a component
	
	def scope_FDRequiredPort_target(FDComponent comp, EReference ref) {
		val List<FCPort> ports = newArrayList
		FCompUtils::collectInheritedPorts(comp.target, FCPortKind.REQUIRED, ports)
		ports.scopeFor
	}
	
	def scope_FDProvidedPort_target(FDComponent comp, EReference ref) {
		val List<FCPort> ports = newArrayList
		FCompUtils::collectInheritedPorts(comp.target, FCPortKind.PROVIDED, ports)
		ports.scopeFor
	}
	
	// *****************************************************************************
	// ports in scope of a service
	
	def scope_FDRequiredPort_target(FDService service, EReference ref) {
		val List<FCPort> ports = newArrayList
		var FCComponent component = null
		val FDComponentInstance instance = service.target
		if (instance.target !== null)
			component = instance.target
		else
			component = instance.prototype.component
		FCompUtils::collectInheritedPorts(component, FCPortKind.REQUIRED, ports)
		ports.scopeFor
	}
	
	def scope_FDProvidedPort_target(FDService service, EReference ref) {
		val List<FCPort> ports = newArrayList
		var FCComponent component = null
		val FDComponentInstance instance = service.target
		if (instance.target !== null)
			component = instance.target
		else
			component = instance.prototype.component
		FCompUtils::collectInheritedPorts(component, FCPortKind.PROVIDED, ports)
		ports.scopeFor
	}

}


