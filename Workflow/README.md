Target git repository: https://bitbucket.cdisc.org/scm/xml/odm-examples.git

The examples in this folsder demonstrate transformations from BPMN2 to CDISC-ODMv2 "WorkflowDef" and vice versa
Example in folder Physiotherapy_Underwatertherapy_BPMN_transformation: The example is about the patient having, during a visit 1, 
the choice between getting physiotherapy, underwater therapy, or both.
After the therapy, the results are evaluated in visit 2.
The folder contains the original BPMN file (BPMN2-XML format), a snapshot picture from a BPMN viewer,
the transformation XSLT stylesheet, and the resulting ODMv2 transformation result.

It also contains the same example ODMv2, created mostly manually - for comparison.

The examples are ODM "snippets", starting from "MetaDataVersion"

The folder ODMv2_to_BPMN2 contains an XSLT (work in progress) for transforming ODMv2 files with "WorkflowDef" sections.

The folder BPMN2_XML-Schemas_specification contains the XML-Schema for BPMN2-XML, for use in validations

The folder BPMNspector contains a Java utility program for validation of BPMN2-XML that goes beyond XML-Schema validation. See http://bpmnspector.org/
