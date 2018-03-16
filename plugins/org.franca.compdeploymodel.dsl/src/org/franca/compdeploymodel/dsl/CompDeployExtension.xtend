package org.franca.compdeploymodel.dsl

import java.util.Collection
import org.franca.deploymodel.extensions.IFDeployExtension
import org.franca.deploymodel.extensions.IFDeployExtension.ElementDef
import org.franca.deploymodel.extensions.IFDeployExtension.Host
import org.franca.deploymodel.extensions.IFDeployExtension.RootDef

class CompDeployExtension implements IFDeployExtension {
	
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
	
	override getShortDescription() {
		"component deployment"
	}

	override Collection<RootDef> getRoots() {
		val root1 = new RootDef(this, "dummy", #[ attribute_setters, attribute_getters, attribute_notifiers, components, services, required_ports, provided_ports, devices, variants, adapters ]) => [
//			addChild(new ElementDef("instanceX", #[ host2, host23 ]) => [
//				addChild(new ElementDef("level2", #[ host23 ]))
//			])
//			addChild(new ElementDef("instanceY", #[ host3, host23 ]))
		]
		#[ root1 ]
	}

}
