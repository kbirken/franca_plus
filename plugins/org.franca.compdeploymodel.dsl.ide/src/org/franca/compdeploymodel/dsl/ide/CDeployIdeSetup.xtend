/*
 * generated by Xtext 2.11.0
 */
package org.franca.compdeploymodel.dsl.ide

import com.google.inject.Guice
import org.eclipse.xtext.util.Modules2
import org.franca.compdeploymodel.dsl.CDeployRuntimeModule
import org.franca.compdeploymodel.dsl.CDeployStandaloneSetup

/**
 * Initialization support for running Xtext languages as language servers.
 */
class CDeployIdeSetup extends CDeployStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new CDeployRuntimeModule, new CDeployIdeModule))
	}
	
}
