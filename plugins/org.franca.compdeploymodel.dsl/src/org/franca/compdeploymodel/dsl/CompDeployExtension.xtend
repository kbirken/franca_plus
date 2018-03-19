package org.franca.compdeploymodel.dsl

import java.util.Collection
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.franca.deploymodel.extensions.IFDeployExtension

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
		#[ ]
	}

	override Map<EClass, Collection<Host>> getAdditionalHosts() {
		#{
			// extend FDAttribute hosts
			FDeployPackage.eINSTANCE.FDAttribute -> #[
				attribute_setters, attribute_getters, attribute_notifiers
			],
			
			// add hosts for all cdepl elements
			CDeployPackage.eINSTANCE.FDComponent -> #[  // TODO: check if correct! Use FDComponentInstance instead?
				components
			],
			CDeployPackage.eINSTANCE.FDService -> #[
				services
			],
			CDeployPackage.eINSTANCE.FDProvidedPort -> #[
				provided_ports
			],
			CDeployPackage.eINSTANCE.FDRequiredPort -> #[
				required_ports
			],
			CDeployPackage.eINSTANCE.FDDevice -> #[
				devices
			],
			CDeployPackage.eINSTANCE.FDVariant -> #[
				variants
			],
			CDeployPackage.eINSTANCE.FDComAdapter -> #[
				adapters
			]
		}
	}

}
