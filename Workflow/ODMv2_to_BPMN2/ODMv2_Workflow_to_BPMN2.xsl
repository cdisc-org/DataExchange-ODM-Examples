
<!-- Prototype stylesheet for transformation from CDISC-ODMv2 to BPMN-2.0 Workflow -->
<!-- currently using namespace "http://schema.omg.org/spec/BPMN/20100524/MODEL" 
	instead of the old? "http://schema.omg.org/spec/BPMN/2.0" for testing in Bonitasoft 5.4 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:bpmn2="http://www.omg.org/spec/BPMN/20100524/MODEL"  version="1.0">
	<xsl:output  method="xml" indent="yes" cdata-section-elements="bpmn2:conditionExpression"/>
	<xsl:template match="/">
		<!-- first get the timings -->
		<!--
		<xsl:variable name="TIMINGS">
			// currently only implemented for TransitionTimingConstraint 
			<xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:Protocol/sdm:Timing/sdm:*">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		-->
		<!-- create the BPMN2 XML -->
		<xsl:element name="bpmn2:definitions">
			<xsl:attribute name="targetNamespace"></xsl:attribute><!-- may be empty -->
			<xsl:for-each select="odm:ODM/odm:Study/odm:WorkflowDef">
				<!-- there should however be only one -->
				<xsl:variable name="ODMDOCUMENT" select="//odm:ODM"/>
				<!--xsl:element name="bpmn2:process"-->
				<xsl:element name="bpmn2:process">
					<!-- take the id attribute from the Study OID -->
					<xsl:attribute name="id">
						<xsl:value-of select="../@OID"/>
					</xsl:attribute>
					<!-- end and start activity -->
					<xsl:if test="odm:WorkflowStart/@StartOID != ''">
						<xsl:variable name="ACTIVITYOID" select="odm:WorkflowStart/@StartOID"/>
						<!-- TODO: case there is an absolute timing constraint on the study start activity -->
						<xsl:element name="bpmn2:startEvent">
							<xsl:attribute name="id">
								<xsl:value-of select="$ACTIVITYOID"/>
							</xsl:attribute>
							<!-- Check whether is a corresponding "Def" -->
							<xsl:choose>
								<xsl:when test="//*[@OID=$ACTIVITYOID]">
									<xsl:attribute name="name">Workflow start</xsl:attribute>
								</xsl:when>
								<xsl:otherwise><xsl:message>WARNING: No "Def" found for Workflow start with OID = <xsl:value-of select="$ACTIVITYOID"/></xsl:message></xsl:otherwise>
							</xsl:choose>
							<!-- Check whether is a corresponding "Def" -->
							<!-- outgoing attribute (there should normally be only one) -->
							<xsl:for-each select="odm:Transition[@SourceOID=$ACTIVITYOID]">
								<xsl:element name="bpmn2:outgoing"><xsl:value-of select="./@OID"/></xsl:element>
							</xsl:for-each>
							<!--  
							<xsl:call-template name="OUTGOING">
								<xsl:with-param name="ODMDOCUMENT" select="$ODMDOCUMENT"/>
								<xsl:with-param name="ACTIVITYOID" select="$ACTIVITYOID"/>
								// xsl:with-param name="TIMINGS" select="$TIMINGS"/
							</xsl:call-template>  -->
						</xsl:element>
					</xsl:if>
					<!-- Triggers are conditional start events -->
					<!--
					<xsl:for-each select="sdm:Trigger">
						// get the condition 
						<xsl:variable name="CONDITIONOID" select="@ConditionOID"/>
						<xsl:variable name="CONDITIONDEF" select="../../../odm:ConditionDef[@OID=$CONDITIONOID]"/>
						<xsl:element name="bpmn2:startEvent">
							<xsl:attribute name="id"><xsl:value-of select="@OID"/></xsl:attribute>
							<xsl:attribute name="name"><xsl:value-of select="@Name"/></xsl:attribute>
							<xsl:element name="conditionalEventDefinition">
								<xsl:element name="condition">
									<xsl:choose>
										<xsl:when test="$CONDITIONDEF/odm:FormalExpression">
											<xsl:value-of select="$CONDITIONDEF/odm:FormalExpression[1]"/>
										</xsl:when>
										<xsl:when test="$CONDITIONDEF/odm:Description/odm:TranslatedText">
											<xsl:value-of select="$CONDITIONDEF/odm:Description/odm:TranslatedText[1]"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$CONDITIONDEF/@Name"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								// incoming and outgoing elements ? 
							</xsl:element>
						</xsl:element>
					</xsl:for-each>  -->
					<!-- timers -->
					<!--
					<xsl:for-each select="$TIMINGS/sdm:TransitionTimingConstraint">
						// P.S. TODO we can as well take the OID of the TransitionTimingConstraint 
						<xsl:variable name="TRANSITIONOID" select="@TransitionDestinationOID"/>
						<xsl:element name="bpmn2:intermediateCatchEvent">
							<xsl:attribute name="id"><xsl:value-of select="concat('TIMER.',$TRANSITIONOID)"/></xsl:attribute>
							// TODO: shouldn't it be better to use Description/TranslatedText for name attribute ? 
							<xsl:attribute name="name">
								<xsl:choose>
									<xsl:when test="odm:Description/odm:TranslatedText">
										<xsl:value-of select="odm:Description/odm:TranslatedText[1]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@Name"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:element name="bpmn2:timerEventDefinition">
								<xsl:element name="bpmn2:timeDuration"><xsl:value-of select="@TimepointRelativeTarget"/></xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:for-each> -->
					<!-- end of timers -->
					<xsl:if test="odm:WorkflowEnd/@EndOID != ''">
						<xsl:variable name="ACTIVITYOID" select="odm:WorkflowEnd/@EndOID"/>
						<xsl:element name="bpmn2:endEvent">
							<xsl:attribute name="id">
								<xsl:value-of select="$ACTIVITYOID"/>
							</xsl:attribute>
							<!-- Check whether there is a corresponding "Def" -->
							<xsl:choose>
								<xsl:when test="//*[@OID=$ACTIVITYOID]">
									<xsl:attribute name="name">Workflow End</xsl:attribute>
								</xsl:when>
								<xsl:otherwise><xsl:message>WARNING: No "Def" found for Workflow end with OID = <xsl:value-of select="$ACTIVITYOID"/></xsl:message></xsl:otherwise>
							</xsl:choose>
							
							<xsl:call-template name="INCOMING">
								<xsl:with-param name="ODMDOCUMENT" select="$ODMDOCUMENT"/>
								<xsl:with-param name="ACTIVITYOID">
									<xsl:value-of select="$ACTIVITYOID"/>
								</xsl:with-param>
								<!--xsl:with-param name="TIMINGS" select="$TIMINGS"/-->
							</xsl:call-template>
						</xsl:element>
					</xsl:if>
					<!-- List of referenced activities (tasks) -->
					<!--xsl:variable name="ODMDOCUMENT" select="//odm:ODM"/-->
					<xsl:message>List of unique BPMN2 tasks:</xsl:message>
					<xsl:for-each select="distinct-values(odm:Transition/@SourceOID | odm:Transition/@TargetOID)">
						<xsl:message>Task: <xsl:value-of select="."/></xsl:message>
						<!-- generate the BPMN2 task -->
						<xsl:variable name="TASKID" select="."/>
						<xsl:if test="$TASKID != $ODMDOCUMENT//odm:WorkflowDef/odm:WorkflowStart/@StartOID and $TASKID != $ODMDOCUMENT//odm:WorkflowDef/odm:WorkflowEnd/@EndOID" >
							<xsl:element name="bpmn2:userTask">
								<xsl:attribute name="id">
									<xsl:value-of select="$TASKID"/>
								</xsl:attribute>
								<!-- now check the "Def" of the task -->
								<xsl:choose>
									<xsl:when test="$ODMDOCUMENT//odm:*[@OID=$TASKID]">
										<!-- get the name -->
										<!-- TODO: probably, ODMPathDef should also have a Name attribute -->
										<xsl:attribute name="name"><xsl:value-of select="$ODMDOCUMENT//odm:*[@OID=$TASKID]/odm:Description/odm:TranslatedText[1]/text()"/></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:message>WARNING: No "Def" found for Activity with OID = <xsl:value-of select="$TASKID"/></xsl:message>
									</xsl:otherwise>
								</xsl:choose>
								<!-- Incoming and Outgoing -->
								<!-- Repaired 2021-05-18 -->
								<xsl:call-template name="INCOMING">
									<xsl:with-param name="ODMDOCUMENT" select="$ODMDOCUMENT"/>
									<xsl:with-param name="ACTIVITYOID" select="$TASKID"/>
									<!--xsl:with-param name="TIMINGS" select="$TIMINGS"/-->
								</xsl:call-template>
								<!-- outgoing flows -->
								<xsl:call-template name="OUTGOING">
									<xsl:with-param name="ODMDOCUMENT" select="$ODMDOCUMENT"/>
									<xsl:with-param name="ACTIVITYOID" select="$TASKID"/>
									<!--xsl:with-param name="TIMINGS" select="$TIMINGS"/-->
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
					
					
					
					<!-- Gateways: there is a gateway (branching) for each "odm:Branching" element -->
					<!-- Remark that for conditional transitions in the branching, 
							the condition is provided on the SequenceFlow element -->
					<!-- TODO: implement parallel branching (ParallelGateway element) -->
					<xsl:for-each select="odm:Branching[@Type='Exclusive' or not(@Type)]">
						<xsl:variable name="BRANCHOID" select="@OID"/>
						<xsl:element name="bpmn2:exclusiveGateway">
							<xsl:attribute name="id">GATEWAY.<xsl:value-of select="$BRANCHOID"/></xsl:attribute>
							<!-- add the default outgoing transition -->
							<xsl:if test="odm:DefaultTransition/@TargetTransitionOID">
								<xsl:attribute name="default"><xsl:value-of select="odm:DefaultTransition/@TargetTransitionOID"/></xsl:attribute>
							</xsl:if>
							<!-- incoming -->
							<!--xsl:message>Generating incoming for Gateway <xsl:value-of select="concat('GATEWAY.',../@OID)"/></xsl:message-->
							<xsl:for-each select="../odm:Transition[@TargetOID=$BRANCHOID]/@OID">
								<xsl:element name="bpmn2:incoming">
									<xsl:value-of select="."/>
								</xsl:element>
							</xsl:for-each>
							<!-- outgoing -->
							<xsl:for-each select="odm:*">
								<xsl:element name="bpmn2:outgoing">
									<xsl:value-of select="@TargetTransitionOID"/>
								</xsl:element>
							</xsl:for-each>
						</xsl:element>
					</xsl:for-each>
					<!-- flow elements -->
					<!-- In case there is branching, we must first define a flowSequence to a Gateway,
						i.e. we here ONLY treat the "Switch" here -->
					<!-- For each Gateway, there must also be a flow to it (and there can be ONLY one in OUR case) -->
					<xsl:for-each select="odm:Transition">
						<xsl:element name="bpmn2:sequenceFlow">
							<xsl:attribute name="id">
								<xsl:value-of select="@OID"/>
							</xsl:attribute>
							<!-- the source is from the SourceOID -->
							<xsl:variable name="SOURCEREFOID" select="@SourceOID"/>
							<!-- take into account that the source may be a branch -->
							<xsl:choose>
								<xsl:when test="../odm:Branching[@OID=$SOURCEREFOID]">
									<xsl:attribute name="sourceRef">GATEWAY.<xsl:value-of select="$SOURCEREFOID"/></xsl:attribute>
								</xsl:when>
								<!-- normal Transition -->
								<xsl:otherwise>
									<xsl:attribute name="sourceRef"><xsl:value-of select="$SOURCEREFOID"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<!-- The target is from the TargetOID -->
							<xsl:variable name="TARGETREFOID" select="@TargetOID"/>
							<!-- take into account that the target may be a branch -->
							<xsl:choose>
								<xsl:when test="../odm:Branching[@OID=$TARGETREFOID]">
									<xsl:attribute name="targetRef">GATEWAY.<xsl:value-of select="$TARGETREFOID"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="targetRef"><xsl:value-of select="$TARGETREFOID"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<!-- The transition is outgoing of a branch and is conditional -->
							<xsl:variable name="TRANSITIONOID" select="@OID"/>
							<xsl:if test="$TRANSITIONOID = ../odm:Branching/odm:TargetTransition[@ConditionOID]/@TargetTransitionOID">
								<xsl:variable name="CONDITIONOID" select="../odm:Branching/odm:TargetTransition[$TRANSITIONOID=@TargetTransitionOID]/@ConditionOID"/>
								<xsl:message>Condition OID for transition = <xsl:value-of select="$CONDITIONOID"/></xsl:message>
								<xsl:variable name="CONDITIONDEF" select="../../odm:MetaDataVersion/odm:ConditionDef[@OID=$CONDITIONOID]"/>
								<xsl:element name="bpmn2:conditionExpression">
									<!-- If there is a description on the corresponding ConditionDef, 
									use it to populate the "documentation" element -->
									<xsl:if test="$CONDITIONDEF/odm:Description/odm:TranslatedText">
										<xsl:element name="bpmn2:documentation"><xsl:value-of select="$CONDITIONDEF/odm:Description/odm:TranslatedText[1]/text()"/></xsl:element>
										<!-- and add the machine-readable expression -->
									</xsl:if>
									<!-- and add the machine-readable expression (cdata sections are defined in xsl:output at top) -->
									<xsl:value-of select="$CONDITIONDEF/odm:FormalExpression[1]/text()"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:for-each>
					
					<!-- conditional transitions:
						These ALWAYS involve branching, so the source IS a gateway  -->
					<!--
					<xsl:for-each select="odm:Branching/odm:TargetTransition | odm:Branching/odm:DefaultTransition">
						<xsl:variable name="TRANSITIONOID" select="../@OID"/> // needed for the definition of the gateway 
						<xsl:variable name="TRANSITIONDESTINATIONOID" select="@OID"/>
						<xsl:element name="bpmn2:sequenceFlow">
							<xsl:attribute name="id">
								<xsl:value-of select="@TargetTransitionOID"/>
							</xsl:attribute>
							<xsl:attribute name="sourceRef">
								// the parent Switch has more than one child element.
									So there is branching, and thus the source is a Gateway 
								<xsl:choose>
									// branching: the source is the gateway
									<xsl:when test="count(../odm:*) gt 1"> // should always be the case 
										<xsl:value-of select="concat('GATEWAY.',$TRANSITIONOID)"/>
									</xsl:when>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="targetRef">
								// in case there is a Timing on this transition, we need an additional timer in between 
								<xsl:choose>
									// there is a timing on this transition 
									<xsl:when test="'A'='B'"></xsl:when>
									/* xsl:when test="../../../../sdm:Timing/sdm:TransitionTimingConstraint[@TransitionDestinationOID=$TRANSITIONDESTINATIONOID]">
										<xsl:message>Generating Timer for targetRef</xsl:message>
										<xsl:value-of select="concat('TIMER.',$TRANSITIONDESTINATIONOID)"/>
									</xsl:when */
									// no timing on this transition
									/* xsl:otherwise>
										<xsl:value-of select="@TargetActivityOID"/>
									</xsl:otherwise */
									<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							// the condition 
							<xsl:if test="name(.)='TargetTransition' and @ConditionOID">
								<xsl:variable name="CONDITIONOID" select="@ConditionOID"/>
								/* get the Condition formalExpression when possible,
									otherwise take the first "Description/TranslatedText" element 
									if that is also not present, just take the short name of the condition
									TODO: pass the language as a parameter to the software  */
								// CONDITIONDEF is a temporary tree 
								<xsl:variable name="CONDITIONDEF" select="//odm:ConditionDef[@OID=$CONDITIONOID]"/>
								<xsl:choose>
									<xsl:when test="$CONDITIONDEF/odm:FormalExpression">
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/odm:FormalExpression[1]"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="$CONDITIONDEF/odm:Description/odm:TranslatedText">
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/odm:Description/odm:TranslatedText[1]"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/@Name"/>
										</xsl:element>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:element>// end of sequenceFlow element
						/* 1.2.2011 if there was a timer inserted, we also need an addition sequenceFlow element
							from the timer to the target element */
						/*
						<xsl:if test="../../../../sdm:Timing/sdm:TransitionTimingConstraint[@TransitionDestinationOID=$TRANSITIONDESTINATIONOID]">
							<xsl:message>Generating additional sequenceFlow FROM Timer </xsl:message>
							<xsl:element name="bpmn2:sequenceFlow">
								<xsl:attribute name="id"><xsl:value-of select="concat('TIMER_',@OID)"/></xsl:attribute>
								<xsl:attribute name="sourceRef"><xsl:value-of select="concat('TIMER.',$TRANSITIONDESTINATIONOID)"/></xsl:attribute>
								<xsl:attribute name="targetRef"><xsl:value-of select="@TargetActivityOID"/></xsl:attribute>
							</xsl:element>
						</xsl:if> */
					</xsl:for-each> -->
					<!-- Conditional transitions from a gateway after a trigger -->
					<!--
					<xsl:for-each select="sdm:Trigger/sdm:Switch/sdm:TransitionDestination">
						// the source is the gateway 
						<xsl:variable name="TRIGGEROID" select="../../@OID"/>// needed for the definition of the gateway 
						<xsl:variable name="TRANSITIONDESTINATIONOID" select="@OID"/>
						<xsl:element name="bpmn2:sequenceFlow">
							// Take Gateways into account 
							<xsl:attribute name="id">
								<xsl:value-of select="@OID"/>
							</xsl:attribute>
							<xsl:attribute name="sourceRef">
								// the parent Switch has more than one child element. So there is branching, and thus the source is a Gateway 
								<xsl:choose>
									// branching: the source is the gateway 
									<xsl:when test="count(../sdm:*) gt 1"> // should always be the case
										<xsl:value-of select="concat('GATEWAY.',$TRIGGEROID)"/>
									</xsl:when>
									// no branching: the source is simply the previous activity - should never be the case 
									<xsl:otherwise>
										<xsl:value-of select="../../@OID"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="targetRef">
								// in case there is a Timing on this transition, we need an additional timer in between 
								<xsl:choose>
									// there is a timing on this transition 
									<xsl:when test="../../../../sdm:Timing/sdm:TransitionTimingConstraint[@TransitionDestinationOID=$TRANSITIONDESTINATIONOID]">
										<xsl:message>Generating Timer for targetRef</xsl:message>
										<xsl:value-of select="concat('TIMER.',$TRANSITIONDESTINATIONOID)"/>
									</xsl:when>
									// no timing on this transition
									<xsl:otherwise>
										<xsl:value-of select="@TargetActivityOID"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							// the condition 
							<xsl:if test="@ConditionOID">
								<xsl:variable name="CONDITIONOID" select="@ConditionOID"/>
								// get the Condition formalExpression when possible,
									otherwise take the first "Description/TranslatedText" element 
									if that is also not present, just take the short name of the condition
									TODO: pass the language as a parameter to the software 
								// CONDITIONDEF is a temporary tree 
								<xsl:variable name="CONDITIONDEF" select="../../../../../odm:ConditionDef[@OID=$CONDITIONOID]"/>
								<xsl:choose>
									<xsl:when test="$CONDITIONDEF/odm:FormalExpression">
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/odm:FormalExpression[1]"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="$CONDITIONDEF/odm:Description/odm:TranslatedText">
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/odm:Description/odm:TranslatedText[1]"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="bpmn2:conditionExpression">
											<xsl:value-of select="$CONDITIONDEF/@Name"/>
										</xsl:element>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:element>// end of sequenceFlow element 
						// 1.2.2011 if there was a timer inserted, we also need an addition sequenceFlow element
							from the timer to the target element 
						<xsl:if test="../../../../sdm:Timing/sdm:TransitionTimingConstraint[@TransitionDestinationOID=$TRANSITIONDESTINATIONOID]">
							<xsl:message>Generating additional sequenceFlow FROM Timer </xsl:message>
							<xsl:element name="bpmn2:sequenceFlow">
								<xsl:attribute name="id"><xsl:value-of select="concat('TIMER_',@OID)"/></xsl:attribute>
								<xsl:attribute name="sourceRef"><xsl:value-of select="concat('TIMER.',$TRANSITIONDESTINATIONOID)"/></xsl:attribute>
								<xsl:attribute name="targetRef"><xsl:value-of select="@TargetActivityOID"/></xsl:attribute>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>// end of loop over sdm:Trigger/sdm:Switch/sdm:TransitionDestination 
					-->
				</xsl:element><!-- end of bpmn:process element -->
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<!-- template for generating "incoming" elements from the Activity OID -->
	<xsl:template name="INCOMING">
		<xsl:param name="ODMDOCUMENT"/>
		<xsl:param name="ACTIVITYOID"/>
		<xsl:param name="TIMINGS"/>
		<xsl:message>Generating 'incoming' for Activity = <xsl:value-of select="$ACTIVITYOID"/></xsl:message>
		<xsl:for-each select="$ODMDOCUMENT//odm:WorkflowDef/odm:Transition[@TargetOID = $ACTIVITYOID]">
			<xsl:variable name="TRANSITIONOID" select="@OID"/>
			<!-- TODO? take care of Gateway -->
			<xsl:element name="bpmn2:incoming"><xsl:value-of select="$TRANSITIONOID"/></xsl:element>
			<!--
			<xsl:choose>
				<xsl:when test="count(../odm:*) gt 1">
					//xsl:message>previous Activity <xsl:value-of select="$SOURCEOID"/> is a branching activity</xsl:message>
					<xsl:variable name="TRANSITIONOID" select="@OID"/>
					// we need to take the gateway transition instead of the activity transition
					// TODO: there is a timing in between the gateway and a timer 
					<xsl:element name="bpmn2:incoming">
						<xsl:value-of select="concat('GATEWAY.',$TRANSITIONOID)"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="count(../odm:*) = 1">
					// the previous activity is not a branching activity, we can simply take the TransitionDefault/@OID 
					<xsl:variable name="TRANSITIONOID" select="@OID"/>
					<xsl:message>Generating INCOMING = <xsl:value-of select="@OID"/></xsl:message>
					<xsl:choose>
						<xsl:when test="$TIMINGS/odm:TransitionTimingConstraint[@TransitionDestinationOID=$TRANSITIONOID]">
							<xsl:element name="bpmn2:incoming"><xsl:value-of select="concat('TIMER.',$TRANSITIONOID)"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="bpmn2:incoming">
								<xsl:value-of select="$TRANSITIONOID"/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:when>
				//
				<xsl:otherwise>
					<xsl:message>MESSAGE: Activity <xsl:value-of select="$ACTIVITYOID"/> does not seeme to have any incoming transitions</xsl:message>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:for-each>
	</xsl:template>
	<!-- template for generate "outgoing" elements from the ActivityOID -->
	<xsl:template name="OUTGOING">
		<xsl:param name="ODMDOCUMENT"></xsl:param>
		<xsl:param name="ACTIVITYOID"/>
		<xsl:param name="TIMINGS"/>
		<xsl:message>Entering OUTGOING template</xsl:message>
		<!--xsl:for-each select="$TIMINGS/*">
			<xsl:message>name = <xsl:value-of select="name(.)"/></xsl:message>
		</xsl:for-each-->
		<xsl:for-each select="$ODMDOCUMENT//odm:WorkflowDef/odm:Transition[@SourceOID=$ACTIVITYOID]">
			<!-- there should be only one -->
			<xsl:variable name="TRANSITIONOID" select="@OID"/>
			<!-- TODO? Branching special case? -->
			<xsl:element name="bpmn2:outgoing"><xsl:value-of select="$TRANSITIONOID"/></xsl:element>
			<!--
			<xsl:choose>
				// if there is more than one target activity, there is branching, 
				// so we need to take a gateway instead 
				<xsl:when test="count(../odm:*) gt 1">
					/* TODO: situation that a timer follows the gateway ? 
						or can this be covered by "INCOMING" template ? */
					<xsl:element name="bpmn2:outgoing">
						<xsl:value-of select="concat('GATEWAY.',$TRANSITIONOID)"/>
					</xsl:element>
				</xsl:when>
				// there is only one transition, and it is (it MUST be) a TransitionDefault 
				<xsl:when test="count(../odm:*) = 1 and ../odm:TransitionDefault">
					/* first check whether there is a TransitionTimingConstraint: 
						in that case the timer is the next element */
					<xsl:variable name="TRANSITIONOID" select="../odm:TransitionDefault/@OID"/>
					<xsl:choose>
						<xsl:when test="$TIMINGS/odm:TransitionTimingConstraint[@TransitionDestinationOID = $TRANSITIONOID]">
							<xsl:message>Inserting TIMER for Transition with OID = <xsl:value-of select="$TRANSITIONOID"/></xsl:message>
							<xsl:element name="bpmn2:outgoing"><xsl:value-of select="concat('TIMER.',$TRANSITIONOID)"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="bpmn2:outgoing">
								<xsl:value-of select="../odm:TransitionDefault/@OID"/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>	
				</xsl:when>
			</xsl:choose> -->
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>