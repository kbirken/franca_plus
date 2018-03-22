/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl

import java.util.Collection
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage
import org.franca.deploymodel.extensions.AbstractFDeployExtension

import static org.franca.deploymodel.extensions.IFDeployExtension.AccessorArgumentStyle.*

/**
 * Implementation of CDeploy deployment extension.</p>
 * 
 * This class registers new deployment hosts and some rules for these hosts.
 * This is the glue between new grammar rules and metamodel class of CDeploy.xtext
 * and the existing logic of Franca deployment.</p>
 * 
 * It will be registered at the IDE via a normal Eclipse extension point.</p>
 * 
 * @author Klaus Birken (itemis AG) 
 */
class CompDeployExtension extends AbstractFDeployExtension {
	
	override getShortDescription() {
		"component deployment"
	}

	val attribute_setters = new Host("attribute_setters")
	val attribute_getters = new Host("attribute_getters")
	val attribute_notifiers = new Host("attribute_notifiers")
	val components = new Host("components")
	val services = new Host("services")
	val required_ports = new Host("required_ports")
	val provided_ports = new Host("provided_ports")
	val devices = new Host("devices")
	val variants = new Host("variants")
	val adapters = new Host("adapters")

	override Map<EClass, Collection<Host>> getAdditionalHosts() {
		#{
			// add hosts for existing FDeploy rules
			fdeploy.getFDAttribute -> #[
				attribute_setters, attribute_getters, attribute_notifiers
			],
			
			// add hosts for all cdepl elements
			cdeploy.FDComponent    -> #[ components ], // TODO: Correct? Use FDComponentInstance instead?
			cdeploy.FDService      -> #[ services ],
			cdeploy.FDProvidedPort -> #[ provided_ports ],
			cdeploy.FDRequiredPort -> #[ required_ports ],
			cdeploy.FDDevice       -> #[ devices ],
			cdeploy.FDVariant      -> #[ variants ],
			cdeploy.FDComAdapter   -> #[ adapters ]
		}
	}

	/**
	 * Define how the deployment elements are identified by generated property accessors.</p>
	 * 
	 * Note that all EClasses not mentioned here will use the default BY_RULE_CLASS,
	 * i.e., the argument type of the property accessor will be the EClass itself. 
	 */
	override Map<EClass, AccessorArgumentStyle> getAccessorArgumentTypes() {
		#{
			fdeploy.FDAttribute -> BY_TARGET_FEATURE
		}
	}

	/** Helper function for easy access to CDeploy EClasses. */
	def private cdeploy() { CDeployPackage.eINSTANCE }
		
}
