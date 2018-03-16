/*
 * generated by Xtext 2.11.0
 */
package org.franca.compdeploymodel.dsl

import com.google.inject.Binder
import com.google.inject.name.Names
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.formatting.IFormatter
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider
import org.eclipse.xtext.validation.CompositeEValidator
import org.franca.deploymodel.dsl.formatting.FDeployFormatter
import org.franca.deploymodel.dsl.valueconverter.FDeployValueConverters

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class CDeployRuntimeModule extends AbstractCDeployRuntimeModule {

	// TODO: is this really needed? remove and test!
	def configureUseEObjectValidator(Binder binder) {
		binder.bind(Boolean).annotatedWith(
			Names.named(CompositeEValidator.USE_EOBJECT_VALIDATOR)
		).toInstance(Boolean.FALSE)
	}

	// support importURI global scoping
	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return ImportUriGlobalScopeProvider
	}

	override Class<? extends IFormatter> bindIFormatter() {
		return FDeployFormatter
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return FDeployValueConverters
	}

}
