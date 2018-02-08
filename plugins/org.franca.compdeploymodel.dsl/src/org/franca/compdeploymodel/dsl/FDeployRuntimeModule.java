/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.compdeploymodel.dsl;

import org.eclipse.xtext.conversion.IValueConverterService;
import org.eclipse.xtext.generator.IGenerator.NullGenerator;
import org.eclipse.xtext.naming.IQualifiedNameProvider;
import org.franca.compdeploymodel.dsl.generator.internal.ImportManager;
import org.franca.compdeploymodel.dsl.valueconverter.FDeployValueConverters;

import com.google.inject.Binder;
import com.google.inject.Singleton;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class FDeployRuntimeModule extends AbstractFDeployRuntimeModule {

	@Override
	public void configure(Binder binder) {
		super.configure(binder);
		binder.bind(ImportManager.class).in(Singleton.class);
	}

	@Override
	public Class<? extends IValueConverterService> bindIValueConverterService() {
		return FDeployValueConverters.class;
	}
	
	@Override
    public Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
        return org.franca.compdeploymodel.dsl.scoping.FDeployDeclarativeNameProvider.class;
    }
	
	@Override 
	public Class<? extends org.eclipse.xtext.generator.IGenerator> bindIGenerator() {
		String noFDeployGenerator = System.getProperty( "noFDeployGenerator");
		if (noFDeployGenerator != null)
			return NullGenerator.class;
		else 
			return super.bindIGenerator();
	}

}
