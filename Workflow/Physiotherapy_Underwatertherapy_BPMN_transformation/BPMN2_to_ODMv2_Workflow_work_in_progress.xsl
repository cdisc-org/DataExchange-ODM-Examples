<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:odm="http://www.cdisc.org/ns/odm/v2.0" xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" version="2.0">
	<xsl:output method="xml" indent="yes"/>
	<!-- XSLT to transform BPMN2 into ODMv2 workflow.
	Author: Jozef Aerts
	Last changes: 2021-01-19 -->
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="bpmn:definitions">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="bpmn:process">
		<xsl:comment>The following represents an ODM snippet (so not a complete study definition) starting from MetaDataVersion</xsl:comment>
		<odm:MetaDataVersion OID="MV.001" Name="MetaDataVersion 1">
			<!-- 2021-02-25: WorkflowDef comes BEFORE StudyEventDef -->
			<!-- Workflow part -->
			<xsl:element name="odm:WorkflowDef">
				<!-- we take the OID from bpmn:process/@id -->
				<xsl:attribute name="OID"><xsl:value-of select="concat('WF.',@id)"/></xsl:attribute>
				<!-- @Name is mandatory, but we cannot retrieve that from the BPMN, so we just hardcode it here -->
				<xsl:attribute name="Name">ODMv2 Workflow generated from BPMN2 using an XSLT stylesheet</xsl:attribute>
				<!-- Define the workflow start - this CAN be an artificial StudyEvent. 
				If you don't want this, comment out the next 3 lines -->
				<!-- TODO: including/excluding start- and end-events can be a parameter -->
				<xsl:element name="odm:WorkflowStart">
					<xsl:attribute name="StartOID"><xsl:value-of select="./bpmn:startEvent/@id"/></xsl:attribute>
				</xsl:element>
				<!-- we first need to define all the transitions - 
					in BPMN2, all transitions are defined twice or three times, once as "incoming" and once as "outgoing", 
					and an additional one as "sequenceFlow" -->
				<!-- we start with all "outgoing" transitions -->
				<!-- we do however want to exclude transitions from the start event and end event for now -->
				<xsl:for-each select="./bpmn:sequenceFlow">
					<xsl:call-template name="createTransition"/>
				</xsl:for-each><!-- end of iteration over sequenceFlow elements -->
				<!-- Define the workflow end - this CAN be an artificial StudyEvent. 
				If you don't want this, comment out the next 3 lines -->
				<!-- TODO: including/excluding start- and end-events can be a parameter -->
				<xsl:element name="odm:WorkflowEnd">
					<xsl:attribute name="EndOID"><xsl:value-of select="./bpmn:endEvent/@id"/></xsl:attribute>
				</xsl:element>
				<!-- Now add all the branches from "exclusiveGateway and parallelGateway -->
				<xsl:for-each select="bpmn:exclusiveGateway">
					<xsl:comment>Branching definition</xsl:comment>
					<xsl:element name="odm:Branching">
						<xsl:attribute name="OID">
							<xsl:value-of select="@id"/>
						</xsl:attribute>
						<xsl:attribute name="Name">
							<xsl:value-of select="@name"/>
						</xsl:attribute>
						<xsl:attribute name="Type">Exclusive</xsl:attribute>
						<!-- add the outgoing transitions -->
						<xsl:for-each select="bpmn:outgoing">
							<xsl:element name="odm:TargetTransition">
								<xsl:variable name="oid" select="concat('TR.',.)"/>
								<xsl:variable name="conditionoid" select="concat('COND.',.)"/>
								<xsl:attribute name="TargetTransitionOID">
									<xsl:value-of select="$oid"/>
								</xsl:attribute>
								<xsl:attribute name="ConditionOID">
									<xsl:value-of select="$conditionoid"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="bpmn:parallelGateway">
					<xsl:element name="odm:Branching">
						<xsl:attribute name="OID">
							<xsl:value-of select="@id"/>
						</xsl:attribute>
						<xsl:attribute name="Name">
							<xsl:value-of select="@name"/>
						</xsl:attribute>
						<xsl:attribute name="Type">Parallel</xsl:attribute>
						<!-- add the outgoing transitions -->
						<xsl:for-each select="bpmn:outgoing">
							<xsl:comment>Remark that there is no Condition reference for parallel execution</xsl:comment>
							<xsl:element name="odm:TargetTransition">
								<xsl:variable name="oid" select="concat('TR.',.)"/>
								<xsl:variable name="conditionoid" select="concat('COND.',.)"/>
								<xsl:attribute name="TargetTransitionOID">
									<xsl:value-of select="$oid"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
			<!-- End of Workflow element -->
			<!-- StudyEventDefs represent activities -->
			<xsl:comment>We model all the tasks as StudyEvents</xsl:comment>
			<xsl:comment>For a repeating task, we would set @Repeating='Yes'</xsl:comment>
			<xsl:comment>2021-01-19: Start- and end-events of BPMN2 are also translated into StudyEvents</xsl:comment>
			<!-- If one wants to exclude BMPN 'startEvent' from the ODM, comment out next line -->
			<xsl:element name="odm:StudyEventDef">
				<xsl:attribute name="OID" select="./bpmn:startEvent/@id"/>
				<xsl:attribute name="Name">Start Event</xsl:attribute>
				<!-- Repeating is hard-coded for the moment -->
				<xsl:attribute name="Repeating">No</xsl:attribute>
			</xsl:element>
			<!-- Create the StudyEventDef-s -->
			<xsl:for-each select="bpmn:task">
				<xsl:call-template name="createStudyEventDef"></xsl:call-template>
			</xsl:for-each>
			<!-- If one wants to exclude BMPN 'endEvent' from the ODM, comment out next line -->
			<xsl:element name="odm:StudyEventDef">
				<xsl:attribute name="OID" select="bpmn:endEvent/@id"/>
				<xsl:attribute name="Name">Start Event</xsl:attribute>
				<!-- Repeating is hard-coded for the moment -->
				<xsl:attribute name="Repeating">No</xsl:attribute>
			</xsl:element>

			<!-- 2021-01-20: subprocesses - each of them goes into a separate WorkflowDef element -->
			<!-- TODO: make this generic using a function, as to treat "deeply nested" subworkflows -->
			<xsl:for-each select="bpmn:subProcess">
				<!-- we need to create additional StudyEventDef instances for the tasks within the subprocess -->
				<xsl:comment>Subprocess StudyEventDef-s for subworkflow with OID = '<xsl:value-of select="@id"/>'</xsl:comment>
				<xsl:for-each select="bpmn:task">
					<xsl:call-template name="createStudyEventDef"/>
				</xsl:for-each>
				<xsl:element name="odm:WorkflowDef">
					<xsl:attribute name="OID"><xsl:value-of select="@id"/></xsl:attribute>
					<xsl:attribute name="Name"><xsl:value-of select="@name"/></xsl:attribute>
				</xsl:element>
			</xsl:for-each>
			<!-- 2019-03-29: Relative timings -->
			<xsl:if test="count(//bpmn:intermediateCatchEvent/bpmn:timerEventDefinition) gt 0">
				<xsl:comment>Timings</xsl:comment>
				<xsl:element name="odm:StudyTiming">
					<xsl:for-each select="//bpmn:intermediateCatchEvent/bpmn:timerEventDefinition">
						<xsl:comment>Relative timing</xsl:comment>
						<!-- possibility 1: we define the timer on the transition itself -->
						<xsl:comment>possibility 1: we define the timer on the transition itself</xsl:comment>
						<xsl:element name="TransitionTimingConstraínt">
							<xsl:attribute name="OID">
								<xsl:value-of select="concat('TIM.',@id)"/>
							</xsl:attribute>
							<xsl:attribute name="Name">Relative timing constraint for:</xsl:attribute>
							<!-- we take incoming flowSequence, as we did for defining the transition itself -->
							<xsl:attribute name="TransitionOID">
								<xsl:value-of select="concat('TR.',../bpmn:incoming/text())"/>
							</xsl:attribute>
							<xsl:attribute name="TimepointRelativeTarget">
								<xsl:value-of select="bpmn:timeDuration/text()"/>
							</xsl:attribute>
						</xsl:element>
						<!-- possibility 2: we define the timer by the source and target Study- or other events -->
						<xsl:comment>possibility 2: we define the timer by the source and target Study- or other events</xsl:comment>
						<xsl:element name="RelativeTimingConstraínt">
							<xsl:attribute name="OID">
								<xsl:value-of select="concat('TIM.',@id)"/>
							</xsl:attribute>
							<xsl:attribute name="Name">Relative timing constraint for:</xsl:attribute>
							<!-- source and target flows -->
							<xsl:variable name="sourceSequenceFlow" select="../bpmn:incoming/text()"/>
							<xsl:variable name="targetSequenceFlow" select="../bpmn:outgoing/text()"/>
							<!-- and from these, get the source and target activities -->
							<xsl:variable name="sourceTask" select="//bpmn:task[bpmn:outgoing/text()=$sourceSequenceFlow]/@id"/>
							<xsl:variable name="targetTask" select="//bpmn:task[bpmn:incoming/text()=$targetSequenceFlow]/@id"/>
							<!-- 2021-01-20: we currently use PredecessorStudyEventOID and SuccessorStudyEventOID, 
							as our tasks are modeled as StudyEvents. 
							ALTERNATIVE: use  generic "PredecessorOID", "SuccessorOID" -->
							<xsl:attribute name="PredecessorStudyEventOID">
								<xsl:value-of select="$sourceTask"/>
							</xsl:attribute>
							<xsl:attribute name="SuccessorStudyEventOID">
								<xsl:value-of select="$targetTask"/>
							</xsl:attribute>
							<xsl:attribute name="TimepointRelativeTarget">
								<xsl:value-of select="bpmn:timeDuration/text()"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>
			<!-- ConditionDef elements from the branching-->
			<xsl:for-each select="bpmn:exclusiveGateway/bpmn:outgoing">
				<xsl:variable name="flowid" select="text()"/>
				<xsl:comment>Important: Note that BPMN2 does not have a mechanism to describe the condition in a machine-readable way</xsl:comment>
				<xsl:element name="odm:ConditionDef">
					<xsl:attribute name="OID">
						<xsl:value-of select="concat('COND.',$flowid)"/>
					</xsl:attribute>
					<xsl:attribute name="Name">Condition for <xsl:value-of select="//bpmn:sequenceFlow[@id=$flowid]/@name"/></xsl:attribute>
					<xsl:element name="odm:Description">
						<xsl:element name="odm:TranslatedText">Condition for <xsl:value-of select="//bpmn:sequenceFlow[@id=$flowid]/@name"/></xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</odm:MetaDataVersion>
	</xsl:template>

	<!-- Functions and Methods (reusable) -->
	<!-- Function to create the StudyEventDef-s -->
	<xsl:template name="createStudyEventDef">
		<xsl:element name="odm:StudyEventDef" namespace="http://www.cdisc.org/ns/odm/v2.0">
			<xsl:attribute name="OID">
				<xsl:value-of select="@id"/>
			</xsl:attribute>
			<xsl:attribute name="Name">
				<xsl:value-of select="@name"/>
			</xsl:attribute>
			<!-- Repeating is hard-coded for the moment -->
			<xsl:attribute name="Repeating">No</xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<!-- Function to create the Transition-s -->
	<xsl:template name="createTransition">
		<!-- get the id -->
		<xsl:variable name="transitionid" select="@id"/>
		<xsl:variable name="sourceref" select="@sourceRef"/>
		<xsl:variable name="targetref" select="@targetRef"/>
		<!-- for the case the target is an intermediateCatchEvent -->
		<xsl:variable name="outgoing" select="//bpmn:intermediateCatchEvent[@id=$targetref]/bpmn:outgoing/text()"/>
		<xsl:variable name="targetTask" select="//bpmn:task[bpmn:incoming/text()=$outgoing]/@name"/>
		<!-- we need a "Name" but it will not always be present, 
							so if it isn't, we just list source and target name -->
		<xsl:variable name="transitionname">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:value-of select="@name"/>
				</xsl:when>
				<!-- TODO: in case of a timer in between, we do not want to have the name of the timer in the "to", 
								but we want to have the name of the subsequent task -->
				<xsl:when test="//bpmn:intermediateCatchEvent/@id = $targetref">Transition from '<xsl:value-of select="//bpmn:outgoing[text()=$transitionid]/../@name"/>' to '<xsl:value-of select="$targetTask"/>'</xsl:when>
				<!-- 2021-01-19: case of start event and end event, these do not have a "name" attribute -->
				<xsl:when test="local-name(//bpmn:outgoing[text()=$transitionid]/..) = 'startEvent'">Transition from 'startEvent' to '<xsl:value-of select="//bpmn:incoming[text()=$transitionid]/../@name"/>'</xsl:when>
				<xsl:when test="local-name(//bpmn:incoming[text()=$transitionid]/..) = 'endEvent'">Transition from '<xsl:value-of select="//bpmn:outgoing[text()=$transitionid]/../@name"/>' to 'endEvent'</xsl:when>
				<!-- the normal case: use the names of source and target taskn -->
				<xsl:otherwise>Transition from '<xsl:value-of select="//bpmn:outgoing[text()=$transitionid]/../@name"/>' to '<xsl:value-of select="//bpmn:incoming[text()=$transitionid]/../@name"/>'</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- source and target id -->
		<xsl:variable name="sourceid">
			<xsl:value-of select="@sourceRef"/>
		</xsl:variable>
		<xsl:variable name="targetid">
			<xsl:value-of select="@targetRef"/>
		</xsl:variable>
		<!-- 2021-01-19: do NOT exclude start and end event transitions  -->
		<!-- we also exclude catching events such as timers -->
		<!-- NEXT line (commented out) is for the case that one want to exclude start- and end-events -->
		<!--xsl:if test="local-name(//*[@id=$sourceid])!='startEvent' and local-name(//*[@id=$targetid])!='endEvent' and local-name(//*[@id=$sourceid])!='intermediateCatchEvent'"-->
		<xsl:if test="local-name(//*[@id=$sourceid])!='intermediateCatchEvent'">
			<xsl:element name="odm:Transition">
				<xsl:attribute name="OID">
					<xsl:value-of select="concat('TR.',@id)"/>
				</xsl:attribute>
				<xsl:attribute name="Name">
					<xsl:value-of select="$transitionname"/>
				</xsl:attribute>
				<!-- what is the source? If it is a "Branching", we need to use "SourceBranchingOID", 
								otherwise it is SourceStudyEventOID -->
				<!--
							<xsl:choose>
								<xsl:when test="local-name(//*[@id=$sourceid])='exclusiveGateway' or local-name(//*[@id=$sourceid])='parallelGateway'">
									<xsl:attribute name="SourceBranchingOID"><xsl:value-of select="$sourceid"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="SourceStudyEventOID"><xsl:value-of select="$sourceid"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>  -->
				<!-- 2019-04-15: we ALWAYS use SourceOID, and make no distinction between what source it is -->
				<xsl:attribute name="SourceOID">
					<xsl:value-of select="$sourceid"/>
				</xsl:attribute>
				<!-- what is the target? If it is a "Branching", we need to use "TargetBranchingOID", 
								otherwise it is TargetStudyEventOID -->
				<!-- 2019-04-15: we ALWAYS use TargetOID, make no distinction between the type of target -->
				<xsl:choose>
					<xsl:when test="local-name(//*[@id=$targetid])='exclusiveGateway' or local-name(//*[@id=$targetid])='parallelGateway'">
						<xsl:attribute name="TargetOID">
							<xsl:value-of select="$targetid"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:when test="local-name(//*[@id=$targetid])='intermediateCatchEvent'">
						<!-- the target is a timer event or another intermediate catch event, 
										we need to find the target that comes AFTER the timer -->
						<xsl:variable name="temp" select="//bpmn:intermediateCatchEvent[@id=$targetid]/bpmn:outgoing/text()"/>
						<xsl:variable name="followingtargettransitionoid" select="//bpmn:sequenceFlow[@id=$temp]/@targetRef"/>
						<xsl:attribute name="TargetOID">
							<xsl:value-of select="$followingtargettransitionoid"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="TargetOID">
							<xsl:value-of select="$targetid"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	
</xsl:stylesheet>