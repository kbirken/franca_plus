/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl

import java.util.Collection
import org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage
import org.franca.deploymodel.extensions.AbstractFDeployExtension

import static org.franca.deploymodel.extensions.IFDeployExtension.HostMixinDef.AccessorArgumentStyle.*

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

	override Collection<HostMixinDef> getMixins() {
		#[
			// add host mixin for existing FDeploy rules
			mixin(fdeploy.getFDAttribute, BY_TARGET_FEATURE,
				#[ attribute_setters, attribute_getters, attribute_notifiers ]
			),

			// add host mixins for all cdepl elements
			mixin(cdeploy.FDComponent,    BY_RULE_CLASS, #[ components ]), // TODO: Correct? Use FDComponentInstance instead?
			mixin(cdeploy.FDService,      BY_RULE_CLASS, #[ services ]),
			mixin(cdeploy.FDProvidedPort, BY_RULE_CLASS, #[ provided_ports ]),
			mixin(cdeploy.FDRequiredPort, BY_RULE_CLASS, #[ required_ports ]),
			mixin(cdeploy.FDDevice,       BY_RULE_CLASS, #[ devices ]),
			mixin(cdeploy.FDVariant,      BY_RULE_CLASS, #[ variants ]),
			mixin(cdeploy.FDComAdapter,   BY_RULE_CLASS, #[ adapters ])
		]
	}

	/** Helper function for easy access to CDeploy EClasses. */
	def private cdeploy() { CDeployPackage.eINSTANCE }
}
