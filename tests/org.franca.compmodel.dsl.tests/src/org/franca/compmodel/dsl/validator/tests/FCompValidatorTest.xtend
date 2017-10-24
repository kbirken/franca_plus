/* Copyright (C) 2017 BMW Group
* Author: Bernhard Hennlich (bernhard.hennlich@bmw.de)
* Author: Manfred Bathelt (manfred.bathelt@bmw.de)
* This Source Code Form is subject to the terms of the Eclipse Public
* License, v. 1.0. If a copy of the EPL was not distributed with this
* file, You can obtain one at https://www.eclipse.org/legal/epl-v10.html. 
 */

package org.franca.compmodel.dsl.validator.tests;


import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.InjectWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.eclipse.xtext.junit4.util.ParseHelper
import org.franca.compmodel.dsl.fcomp.FCModel
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.compmodel.dsl.tests.util.MultiInjectorProvider
import org.franca.compmodel.dsl.fcomp.FcompPackage
import org.junit.Assert

@RunWith(XtextRunner2)
@InjectWith(MultiInjectorProvider)
class FCompValidatorTest
{
	@Inject extension ValidationTestHelper
	@Inject extension ParseHelper<FCModel>
	
	@Test
	def void TestduplicateDelegate()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					provides WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					requires WindowLifter as RDriverPort
					requires WindowLifter as RCoDriverPort
				}
				
				
				component BodyCluster {
					provides WindowLifter as PDriverPort
				    provides WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect WindowLifterMasterPrototype.RDriverPort to DriverWindowLifterPrototype.PPort
					connect WindowLifterMasterPrototype.RCoDriverPort to CoDriverWindowLifterPrototype.PPort
					
					delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
					delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_DELEGATE_CONNECTOR, null,
			"Duplication of delegates is not allowed")
	}
	
	@Test
	def void TestDifferentTypOfInnerAndOuter()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					requires WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					provides WindowLifter as RDriverPort
					provides WindowLifter as RCoDriverPort
				}
				
				
				component BodyCluster {
					requires WindowLifter as PDriverPort
				    requires WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect DriverWindowLifterPrototype.PPort to WindowLifterMasterPrototype.RDriverPort
					connect CoDriverWindowLifterPrototype.PPort to WindowLifterMasterPrototype.RCoDriverPort
					
					delegate required PDriverPort to DriverWindowLifterPrototype.PPort
					delegate required PCoDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).delegates.get(0).validate
		var first = issues.findFirst[it.message.contains("PDriverPort")]
		Assert.assertEquals(first.message, "Required delegate must not connect to different outer 'PDriverPort'")
		var second = issues.findFirst[it.message.contains("PCoDriverPort")]
		Assert.assertEquals(second.message, "Required delegate must not connect to different outer 'PCoDriverPort'")
	}
	
	@Test
	def void TestduplicateProvidedDelegateOuter()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					provides WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					requires WindowLifter as RDriverPort
					requires WindowLifter as RCoDriverPort
				}
				
				component BodyCluster {
					provides WindowLifter as PDriverPort
				    provides WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect WindowLifterMasterPrototype.RDriverPort to DriverWindowLifterPrototype.PPort
					connect WindowLifterMasterPrototype.RCoDriverPort to CoDriverWindowLifterPrototype.PPort
					
					delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
					delegate provided PDriverPort to CoDriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).delegates.get(0).validate
		var first = issues.findFirst[it.message.contains("'DriverWindowLifterPrototype")]
		Assert.assertEquals(first.message, "Duplicate provided delegate outer to 'DriverWindowLifterPrototype.PPort'")
		var second = issues.findFirst[it.message.contains("CoDriverWindowLifterPrototype")]
		Assert.assertEquals(second.message, "Duplicate provided delegate outer to 'CoDriverWindowLifterPrototype.PPort'")
		
	}
	
	@Test
	def void TestduplicateProvidedDelegateInner()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					provides WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					requires WindowLifter as RDriverPort
					requires WindowLifter as RCoDriverPort
				}
				
				component BodyCluster {
					provides WindowLifter as PDriverPort
				    provides WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect WindowLifterMasterPrototype.RDriverPort to DriverWindowLifterPrototype.PPort
					connect WindowLifterMasterPrototype.RCoDriverPort to CoDriverWindowLifterPrototype.PPort
					
					delegate provided PDriverPort to DriverWindowLifterPrototype.PPort
					delegate provided PCoDriverPort to DriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).delegates.get(0).validate
		var first = issues.findFirst[it.message.contains("PDriverPort")]
		Assert.assertEquals(first.message, "Duplicate provided delegate inner from 'PDriverPort'")
		var second = issues.findFirst[it.message.contains("PCoDriverPort")]
		Assert.assertEquals(second.message, "Duplicate provided delegate inner from 'PCoDriverPort'")
	}
	
	@Test
	def void TestduplicatedAssemblyFromConnector()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
					provides WindowLifter as PPort
				}
				
				service component WindowLifterMaster {
					requires WindowLifter as RDriverPort
					requires WindowLifter as RCoDriverPort
				}
				
				component BodyCluster {
					provides WindowLifter as PDriverPort
				    provides WindowLifter as PCoDriverPort
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
					
					contains WindowLifterMaster as WindowLifterMasterPrototype
						
					connect WindowLifterMasterPrototype.RDriverPort to DriverWindowLifterPrototype.PPort
					connect WindowLifterMasterPrototype.RDriverPort to CoDriverWindowLifterPrototype.PPort
				}
		'''.parse
		
		var issues = model.components.get(2).assembles.get(0).validate
		var first = issues.findFirst[it.message.contains("'DriverWindowLifterPrototype")]
		Assert.assertEquals(first.message, "Assembly port already connected to 'DriverWindowLifterPrototype.PPort'")
		var second = issues.findFirst[it.message.contains("'CoDriverWindowLifterPrototype")]
		Assert.assertEquals(second.message, "Assembly port already connected to 'CoDriverWindowLifterPrototype.PPort'")
		var third = issues.findFirst[it.message.contains("Duplication")]
		Assert.assertEquals(third.message, "Duplication of assembly connectors is not allowed")
		var found = issues.filter[it.message.contains("Duplication")]
		Assert.assertEquals(2, found.size)
	}

	@Test
	def void TestSingeltonComponentValidation()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service singleton component WindowLifter {
					provides WindowLifter as PPort
				}
				
				component BodyCluster {
				    	
					contains WindowLifter as DriverWindowLifterPrototype
					contains WindowLifter as CoDriverWindowLifterPrototype
				}
		'''.parse
		
		var issues = model.components.get(1).prototypes.get(0).validate
		issues.forEach[Assert.assertEquals(it.message, "Duplicate containment for singleton 'WindowLifter'")]
		Assert.assertEquals(2, issues.size)
		
	}
	
	@Test
	def void TestUniquePortNames()
	{
		var model = '''
		package org.example 
		import org.example.* from "testfidls/WindowLifter.fidl"
						
		service component WindowLifter 
		{
		provides WindowLifter as PPort
		provides WindowLifter as PPort
		}'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROVIDED_PORT, null,
			"Port name must be unique '" + model.components.get(0).providedPorts.get(0).name + "'"
		)
		
	}
	
	@Test
	def void TestUniqueComponentRefNames()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter {
				provides WindowLifter as PPort
				}
				
				component BodyCluster {
				contains WindowLifter as DriverWindowLifterPrototype
				contains WindowLifter as DriverWindowLifterPrototype
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null,
			"Component alias must be unique '" + model.components.get(1).prototypes.get(0).name + "'"
		)
	}
	
	@Test
	def void TestUniqueComponentNames()
	{
		var model = '''
				package org.example
				import org.example.* from "testfidls/WindowLifter.fidl"
				
				service component WindowLifter{
				provides WindowLifter as PPort
				}
				
				component WindowLifter{
				provides WindowLifter as PPort
				}
		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_COMPONENT, null,
			"Component name must be unique '" + model.components.get(0).name + "'"
		)
	}
	
	@Test
	def void TestSimplePortNames()
	{
		var model = '''
		package org.example
		import org.example from "testfidls/WindowLifter.fidl"
						
		service component WindowLifter{
		provides org.example.WindowLifter
		}
		'''.parse
		model.validate
		println(model.components.get(0).providedPorts.get(0).name)
		model.assertError(FcompPackage.Literals.FC_PROVIDED_PORT, null,
			"Implicit port name must be simple name. No namespace separators allowed in '" + model.components.get(0).providedPorts.get(0).name + "'"
		)
	}

	@Test
	def void TestForSelfContainment()
	{
		var model = '''
		package org.example
		import org.example.* from "testfidls/WindowLifter.fidl"
						
		service component WindowLifter {
		contains WindowLifter		
		}

		'''.parse
		
		model.assertError(FcompPackage.Literals.FC_PROTOTYPE, null,
			"Component \'" + model.components.get(0).prototypes.get(0).component.name + "\' must not contain prototype of component, which is already present in hierarchy"
		)
	}
}
	