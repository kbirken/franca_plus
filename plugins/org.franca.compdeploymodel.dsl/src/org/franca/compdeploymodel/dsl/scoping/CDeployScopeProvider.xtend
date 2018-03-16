package org.franca.compdeploymodel.dsl.scoping

import com.google.common.base.Predicate
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
import org.franca.deploymodel.dsl.fDeploy.FDTypes

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
		PropertyMappings::getAllPropertyDecls(root.getSpec(), elem).scopeFor
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
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDService
			}
		}
		new FilteringScope(delegateScope, filter)
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
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				od.EObjectOrProxy instanceof FDDevice 
			}
		}
		new FilteringScope(delegateScope, filter)
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
		if (adapter.eContainer instanceof FDDevice) {
			val pPorts = (adapter.eContainer as FDDevice).use.filter(FDService).map[providedPorts].flatten
			val rPorts = (adapter.eContainer as FDDevice).use.filter(FDService).map[requiredPorts].flatten
			val IScope delegateScope = delegateGetScope(adapter, ref)
			val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
				override boolean apply(IEObjectDescription od) {
					val port = od.EObjectOrProxy
					if (port instanceof FDProvidedPort)
						pPorts.exists[it == port && haveCompatibleSpecs(adapter, port)]
					else if (port instanceof FDRequiredPort)
						rPorts.exists[it == port && haveCompatibleSpecs(adapter, port)]
					else 
						false
				}
			}
			new FilteringScope(delegateScope, filter)
		}
		else
			IScope::NULLSCOPE
	}
	
	/**
	 * Limit scope to deployed type collections in an interface deployment context
	 */
	def IScope scope_FDRootElement_use(FDInterface fdif, EReference ref) {
		val IScope delegateScope = delegateGetScope(fdif, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDTypes
			}
		}
		new FilteringScope(delegateScope, filter)
	}	
	
	
	/**
	 * Limit scope for component to compatible components deployments in a service context
	 */
	def IScope scope_FDRootElement_use(FDService service, EReference ref) {
		val componentType = service.target.prototype?.component ?: service.target.target
		val IScope delegateScope = delegateGetScope(service, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				if (obj instanceof FDComponent)
					obj.target == componentType
				else 
					false
			}
		}
		new FilteringScope(delegateScope, filter)
	}	
	
	/**
	 * Limit scope to components deployments in a component context
	 */
	def IScope scope_FDRootElement_use(FDComponent component, EReference ref) {
		val IScope delegateScope = delegateGetScope(component, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val obj = od.EObjectOrProxy
				obj instanceof FDComponent
			}
		}
		new FilteringScope(delegateScope, filter)
	}
	
	/**
	 * Limit scope to types deployments in a typeCollection context
	 */
	def IScope scope_FDRootElement_use(FDTypes types, EReference ref) {
		val IScope delegateScope = delegateGetScope(types, ref)
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				od.EObjectOrProxy instanceof FDTypes
			}
		}
		new FilteringScope(delegateScope, filter)
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
		
		val Predicate<IEObjectDescription> filter = new Predicate<IEObjectDescription>() {
			override boolean apply(IEObjectDescription od) {
				val object = od.EObjectOrProxy
				if (object instanceof FDInterface)
					inheritedInterfaces.contains(object.target) 
					&& haveCompatibleSpecs(port, object) 
				else 
					false
			}
		}
		new FilteringScope(delegateScope, filter)
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



	/*
	 * Compatible means either a childs spec parent and child reference the same spec 
	 * or child spec is derived from parent spec.
	 */
	def private haveCompatibleSpecs (FDRootElement parent, FDRootElement child) {
		var parentSpec = parent.spec
		if (parentSpec === null)
			parentSpec = getRootElement(parent.eContainer as FDElement)?.spec
		
		var check = child.spec
		if (check === null)
			check = getRootElement(child.eContainer as FDElement)?.spec
		
		while (check !== null) {
			if (parentSpec == check)
				return true
			check = check.base
		} 
		return false
	}

}


