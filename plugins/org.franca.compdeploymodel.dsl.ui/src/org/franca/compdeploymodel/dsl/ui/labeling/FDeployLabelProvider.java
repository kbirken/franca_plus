/*
 * generated by Xtext
 */
package org.franca.compdeploymodel.dsl.ui.labeling;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.jface.viewers.StyledString.Styler;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.utils.TextStyle;
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider;
import org.eclipse.xtext.ui.label.InjectableAdapterFactoryLabelProvider;
import org.eclipse.xtext.ui.label.StylerFactory;
import org.franca.compdeploymodel.core.FDModelUtils;
import org.franca.compdeploymodel.core.GenericPropertyAccessor;
import org.franca.compdeploymodel.core.PropertyMappings;
import org.franca.compdeploymodel.dsl.fDeploy.FDArgument;
import org.franca.compdeploymodel.dsl.fDeploy.FDArray;
import org.franca.compdeploymodel.dsl.fDeploy.FDAttribute;
import org.franca.compdeploymodel.dsl.fDeploy.FDBoolean;
import org.franca.compdeploymodel.dsl.fDeploy.FDBroadcast;
import org.franca.compdeploymodel.dsl.fDeploy.FDComAdapter;
import org.franca.compdeploymodel.dsl.fDeploy.FDComponent;
import org.franca.compdeploymodel.dsl.fDeploy.FDComponentInstance;
import org.franca.compdeploymodel.dsl.fDeploy.FDDeclaration;
import org.franca.compdeploymodel.dsl.fDeploy.FDDevice;
import org.franca.compdeploymodel.dsl.fDeploy.FDElement;
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumeration;
import org.franca.compdeploymodel.dsl.fDeploy.FDEnumerator;
import org.franca.compdeploymodel.dsl.fDeploy.FDField;
import org.franca.compdeploymodel.dsl.fDeploy.FDGeneric;
import org.franca.compdeploymodel.dsl.fDeploy.FDInteger;
import org.franca.compdeploymodel.dsl.fDeploy.FDInterface;
import org.franca.compdeploymodel.dsl.fDeploy.FDInterfaceInstance;
import org.franca.compdeploymodel.dsl.fDeploy.FDMethod;
import org.franca.compdeploymodel.dsl.fDeploy.FDModel;
import org.franca.compdeploymodel.dsl.fDeploy.FDProperty;
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertyDecl;
import org.franca.compdeploymodel.dsl.fDeploy.FDPropertySet;
import org.franca.compdeploymodel.dsl.fDeploy.FDProvidedPort;
import org.franca.compdeploymodel.dsl.fDeploy.FDRequiredPort;
import org.franca.compdeploymodel.dsl.fDeploy.FDService;
import org.franca.compdeploymodel.dsl.fDeploy.FDString;
import org.franca.compdeploymodel.dsl.fDeploy.FDStruct;
import org.franca.compdeploymodel.dsl.fDeploy.FDTypeOverwrites;
import org.franca.compdeploymodel.dsl.fDeploy.FDTypedef;
import org.franca.compdeploymodel.dsl.fDeploy.FDTypes;
import org.franca.compdeploymodel.dsl.fDeploy.FDUnion;
import org.franca.compdeploymodel.dsl.fDeploy.FDVariant;
import org.franca.compdeploymodel.dsl.fDeploy.Import;
import org.franca.core.franca.FType;

import com.google.inject.Inject;

/**
 * Provides labels for a EObjects.
 * 
 * see
 * http://www.eclipse.org/Xtext/documentation/latest/xtext.html#labelProvider
 */
public class FDeployLabelProvider extends DefaultEObjectLabelProvider {

	private final String DEFAULT_PROPERTY_MARKER = "?";
	private final String DEFAULT_VALUE_MARKER = "?=";

	private final StylerFactory stylerFactory;
	private final DefaultHighlightingConfiguration configuration;


	@Inject
	public FDeployLabelProvider(InjectableAdapterFactoryLabelProvider delegate, StylerFactory stylerFactory,
			DefaultHighlightingConfiguration configuration) {
		super(delegate);
		this.stylerFactory = stylerFactory;
		this.configuration = configuration;
	}

	public String text(FDMethod element) {
		return element.getTarget().getName();
	}

	public String text(FDAttribute element) {
		return element.getTarget().getName();
	}

	public String text(FDBroadcast element) {
		return element.getTarget().getName();
	}

	public String text(FDArgument element) {
		return element.getTarget().getName();
	}
	
	public String text(FDArray element) {
		return element.getTarget().getName();
	}
	
	public String text(FDEnumeration element) {
		return element.getTarget().getName();
	}

	public String text(FDField element) {
		return element.getTarget().getName();
	}

	public String text(FDStruct element) {
		return element.getTarget().getName();
	}

	public String text(FDUnion element) {
		return element.getTarget().getName();
	}

	public String text(FDTypedef element) {
		return element.getTarget().getName();
	}

	public String text(FDProperty element) {
		return element.getDecl().getName();
	}

	public String text(FDVariant element) {
		return element.getName();
	}
	
	public String text(FDTypeOverwrites element) {
		return "overwrites";
	}

	public String text(FDInteger element) {
		return getDefaultMarker(element) + String.valueOf(element.getValue());
	}

	public String text(FDString element) {
		return getDefaultMarker(element) + element.getValue();
	}

	public String text(FDBoolean element) {
		return getDefaultMarker(element) + element.getValue();
	}

	public String text(FDGeneric element) {
		String dm = getDefaultMarker(element);
		if (FDModelUtils.isEnumerator(element)) {
			return dm + FDModelUtils.getEnumerator(element).getName();
		}
		if (FDModelUtils.isInstanceRef(element)) {
			return dm + FDModelUtils.getInstanceRef(element).getName();
		}
		return dm + "UNKNOWN"; // shouldn't happen
	}

	public String text(FDEnumerator element) {
		return getDefaultMarker(element) + element.getName();
	}

	public String text(FDDeclaration element) {
		String name = element.getHost().getLiteral();

		return name.substring(0, 1).toUpperCase() + name.substring(1).toLowerCase();
	}

	public String text(FDPropertyDecl element) {
		String name = new String();

		if (!PropertyMappings.isMandatory(element)) {
			name += DEFAULT_PROPERTY_MARKER;
		}
		name += element.getName();
		return name;
	}

	public StyledString text(FDTypes element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}
	
	public StyledString text(FDInterfaceInstance element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}
	
	public StyledString text(FDInterface element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}
	
	public StyledString text(FDDevice element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}

	public StyledString text(FDComAdapter element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}

	public StyledString text(FDService element) {
		return getStyledStringForElement(element.getName(), element.getTarget().getName());
	}

	public StyledString text(FDRequiredPort element) {
		return getStyledStringForElement(element.getName(), 
				element.getSpec() != null ? element.getSpec().getName() : 
					FDModelUtils.getRootElement(((FDElement)element.eContainer())).getSpec().getName());
	}

	public StyledString text(FDProvidedPort element) {
		return getStyledStringForElement(element.getName(), 
				element.getSpec() != null ? element.getSpec().getName() : 
					FDModelUtils.getRootElement(((FDElement)element.eContainer())).getSpec().getName());
	}

	public StyledString text(FDComponent element) {
		return getStyledStringForElement(element.getName(), 
				element.getSpec() != null ? element.getSpec().getName() : 
					FDModelUtils.getRootElement(((FDElement)element.eContainer())).getSpec().getName());
	}

	public String text(FDPropertySet element) {
		return "properties";
	}

	public String getDefaultMarker(EObject element) {
		if (GenericPropertyAccessor.isSpecification(element)) {
			if (GenericPropertyAccessor.isDefault(element)) {
				return DEFAULT_VALUE_MARKER;
			}
		}
		return "";
	}

	private StyledString getStyledStringForElement(String name, String targetName) {
		String elementName = name != null ? name : targetName;
		Styler style = stylerFactory.createXtextStyleAdapterStyler(configuration.defaultTextStyle());
		StyledString styledString = new StyledString(elementName, style);

		// append derived type in italic
		if (name != null) {
			TextStyle textStyle = new TextStyle();
			FontData[] fontData = JFaceResources.getDialogFont().getFontData();
			fontData[0].setStyle(SWT.ITALIC);
			textStyle.setFontData(fontData);
			textStyle.setColor(new RGB(0, 0, 0));
			styledString.append(" [");
			;
			styledString.append(stylerFactory.createFromXtextStyle(targetName, textStyle));
			styledString.append(']');
		}

		return styledString;
	}

	public String image(FDInterface element) {
		return "interface.png";
	}

	public String image(FDAttribute element) {
		return "attribute.gif";
	}

	public String image(FDMethod element) {
		return "method.gif";
	}

	public String image(FDField element) {
		return "field.gif";
	}

	public String image(FDPropertySet element) {
		return "yellowlabel.png";
	}
	
	public String image(FDProperty element) {
		return "yellowlabel.png";
	}

	public String image(FDGeneric element) {
		if (FDModelUtils.isEnumerator(element)) {
			return "enum.gif";
		}
		if (FDModelUtils.isInstanceRef(element)) {
			return "interface.png"; // TODO: replace by specific icon
		}
		return null; // shouldn't happen
	}

	public String image(FDEnumerator element) {
		return "enumerator.gif";
	}
	
	public String image(FDEnumeration element) {
		return "enum.gif";
	}
	
	public String image(FDArray element) {
		return "arrays.png";
	}

	public String image(FType element) {
		return "types.gif";
	}

	public String image(FDStruct element) {
		return "struct.gif";
	}

	public String image(FDUnion element) {
		return "struct.gif"; // TODO: different image for unions?
	}

	public String image(Import element) {
		return "import.gif";
	}

	public String image(FDTypeOverwrites element) {
		return "overwrite.png";
	}
	
	public String image(FDBroadcast element) {
		return "event.png";
	}

	public String image(FDService element) {
		return "instance.png";
	}

	public String image(FDComponentInstance element) {
		return "instance.png";
	}

	public String image(FDDevice element) {
		return "deployment.png";
	}

	public String image(FDComAdapter element) {
		return "adapter.png";
	}

	public String image(FDProvidedPort element) {
		return "provides.png";
	}

	public String image(FDRequiredPort element) {
		return "requires.png";
	}

	public String image(FDComponent element) {
		return "component.png";
	}

	public String image(FDModel element) {
		return "package.png";
	}

	public String image(FDVariant element) {
		return "variant.png";
	}
	
	public String image(FDTypes element) {
		return "types.gif";
	}

	public String image(FDArgument element) {
		EObject parent = element.eContainer().eContainer();
		if (parent instanceof FDBroadcast || (parent instanceof FDMethod
				&& ((FDMethod) parent).getOutArguments().getArguments().contains(element))) {
			return "overlay-out.gif";
		} else {
			return "overlay-in.gif";
		}
	}

	public String image(FDDeclaration element) {
		switch (element.getHost()) {
		case INTERFACES:
			return "interface.png";
		case ATTRIBUTES:
			return "attribute.gif";
		case METHODS:
			return "method.gif";
		case STRUCT_FIELDS:
			return "field.gif";
		case UNION_FIELDS:
			return "field.gif";
		case FIELDS:
			return "field.gif";
		case ENUMERATIONS:
			return "enum.gif";
		case ENUMERATORS:
			return "enumerator.gif";
		case BROADCASTS:
			return "event.png";
		case STRINGS:
			return "strings.png";
		case NUMBERS: // fall-through
		case INTEGERS: // fall-through
		case FLOATS:
			return "numbers.png";
		case ARRAYS:
			return "arrays.png";
		case DEVICES:
			return "device.png";
		case SERVICES:
			return "service.png";
		case PROVIDED_PORTS:
			return "provides.png";
		case REQUIRED_PORTS:
			return "requires.png";
		case ADAPTERS:
			return "adapter.png";

		default:
			return null;
		}
	}
}
