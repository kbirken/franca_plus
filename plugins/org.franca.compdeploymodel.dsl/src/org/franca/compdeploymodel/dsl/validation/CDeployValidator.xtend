/*
 * generated by Xtext 2.11.0
 */
package org.franca.compdeploymodel.dsl.validation

import org.eclipse.xtext.validation.Check
import org.franca.compdeploymodel.dsl.CompDeployExtension
import org.franca.compdeploymodel.dsl.cDeploy.FDComponent
import org.franca.deploymodel.core.FDModelUtils
import org.franca.deploymodel.core.FDPropertyHost
import org.franca.deploymodel.dsl.FDSpecificationExtender

import static org.franca.compdeploymodel.dsl.cDeploy.CDeployPackage.Literals.*
import static org.franca.deploymodel.dsl.fDeploy.FDeployPackage.Literals.*

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CDeployValidator extends AbstractCDeployValidator {

	val static PROVIDED_PORTS = new FDPropertyHost(CompDeployExtension.PROVIDED_PORTS)
	val static REQUIRED_PORTS = new FDPropertyHost(CompDeployExtension.REQUIRED_PORTS)
	
	@Check def void checkPropertiesComplete(FDComponent elem) {
		var int lowerLevelErrors = 0

		// check own properties
		val spec = FDModelUtils.getRootElement(elem).spec
		if (checkSpecificationElementProperties(spec, elem, FD_ROOT_ELEMENT__NAME, spec.name)) {
			lowerLevelErrors++
		}

		// check child elements recursively
		val specHelper = new FDSpecificationExtender(spec)
		val target = elem.target
		for(port : target.providedPorts) {
			val p = elem.providedPorts.findFirst[it.target==port]
			if (p === null) {
				if (specHelper.isMandatory(PROVIDED_PORTS)) {
					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«port.name»'«»''',
						FD_COMPONENT__TARGET, port.name)
//					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«port.name»'«»''',
//						FD_COMPONENT__TARGET, DEPLOYMENT_ELEMENT_QUICKFIX, port.name,
//						"QuickFixConstantPortTODO")
					lowerLevelErrors++
				}
			} else if (checkSpecificationElementProperties(spec, p, FD_PROVIDED_PORT__TARGET, port.name)) {
				lowerLevelErrors++
			}
		}
		for(port : target.requiredPorts) {
			val p = elem.requiredPorts.findFirst[it.target==port]
			if (p === null) {
				if (specHelper.isMandatory(REQUIRED_PORTS)) {
					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«port.name»'«»''',
						FD_COMPONENT__TARGET, port.name)
//					error('''«DEPLOYMENT_ELEMENT_QUICKFIX_MESSAGE»'«»«port.name»'«»''',
//						FD_COMPONENT__TARGET, DEPLOYMENT_ELEMENT_QUICKFIX, port.name,
//						"QuickFixConstantPortTODO")
					lowerLevelErrors++
				}
			} else if (checkSpecificationElementProperties(spec, p, FD_REQUIRED_PORT__TARGET, port.name)) {
				lowerLevelErrors++
			}
		}

		// show a global quickfix on the root element, if any error on the detail level occurred
		if (lowerLevelErrors > 0) {
			// Recursive quickfix can be added for the top level FDInterface element
//			error('''«DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX_MESSAGE»'«»«spec.name»'«»''', elem,
//				FD_COMPONENT__TARGET, DEPLOYMENT_ELEMENT_RECURSIVE_QUICKFIX, spec.name,
//				"QuickFixConstantPortTODO")
		}
	}

}
