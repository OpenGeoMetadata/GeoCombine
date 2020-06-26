<?xml version="1.0" encoding="UTF-8"?>
<!--      iso2html.xsl - Transformation from ISO 19139 into HTML      Created by Kim Durante, Stanford University Libraries          TODO: Needs full Data Quality section mapped           Not sure if complete contactInfo is needed for each Responsible Party?                -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"    xmlns:xlink="http://www.w3.org/1999/xlink"    xmlns:gmd="http://www.isotc211.org/2005/gmd"     xmlns:gco="http://www.isotc211.org/2005/gco"     xmlns:gts="http://www.isotc211.org/2005/gts"     xmlns:srv="http://www.isotc211.org/2005/srv"     xmlns:gml="http://www.opengis.net/gml"    exclude-result-prefixes="gmd gco gml srv xlink gts">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
        </title>
      </head>
      <body>
        <h1>
          <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
        </h1>
        <ul>
          <xsl:if test="gmd:MD_Metadata/gmd:identificationInfo">
            <li>
              <a href="#iso-identification-info">Identification Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata/gmd:referenceSystemInfo">
            <li>
              <a href="#iso-spatial-reference-info">Spatial Reference Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata/gmd:dataQualityInfo">
            <li>
              <a href="#iso-data-quality-info">Data Quality Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata/gmd:distributionInfo">
            <li>
              <a href="#iso-distribution-info">Distribution Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata/gmd:contentInfo">
            <li>
              <a href="#iso-content-info">Content Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata/gmd:spatialRepresentationInfo">
            <li>
              <a href="#iso-spatial-representation-info">Spatial Representation Information</a>
            </li>
          </xsl:if>
          <xsl:if test="gmd:MD_Metadata">
            <li>
              <a href="#iso-metadata-reference-info">Metadata Reference Information</a>
            </li>
          </xsl:if>
        </ul>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="gmd:MD_Metadata">
    <div id="iso-identification-info">
      <dl>
        <dt>Identification Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation">
              <dt>Citation</dt>
              <dd>
                <dl>
                  <dt>Title</dt>
                  <dd>
                    <xsl:value-of select="gmd:title"/>
                  </dd>
                  <xsl:choose>
                    <xsl:when test="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
                      <xsl:for-each select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
                        <dt>Originator</dt>
                        <dd>
                          <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                        </dd>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact">
                      <xsl:for-each select="//gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact">
                        <xsl:if test="gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue='originator'">
                          <dt>Originator</dt>
                          <dd>
                            <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName | gmd:CI_ResponsibleParty/gmd:individualName"/>
                          </dd>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:for-each select="gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='publisher']">
                    <dt>Publisher</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                    </dd>
                    <xsl:if test="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city">
                      <dt>Place of Publication</dt>
                      <dd>
                        <xsl:value-of select="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city"/>
                        <xsl:if test="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea">
                          <xsl:text>,</xsl:text>
                          <xsl:value-of select="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea"/>
                        </xsl:if>
                        <xsl:if test="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country">
                          <xsl:text>,</xsl:text>
                          <xsl:value-of select="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country"/>
                        </xsl:if>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:date/gmd:CI_Date">
                    <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'publication')">
                      <dt>Publication Date</dt>
                      <dd>
                        <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'creation')">
                      <dt>Creation Date</dt>
                      <dd>
                        <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'revision')">
                      <dt>Revision Date</dt>
                      <dd>
                        <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="gmd:edition">
                    <dt>Edition</dt>
                    <dd>
                      <xsl:value-of select="gmd:edition"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:identifier/gmd:MD_Identifier/gmd:code">
                    <dt>Identifier</dt>
                    <dd>
                      <xsl:value-of select="gmd:identifier/gmd:MD_Identifier/gmd:code"/>
                    </dd>
                  </xsl:if>
                  <xsl:for-each select="gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue">
                    <dt>Geospatial Data Presentation Form</dt>
                    <dd>
                      <xsl:value-of select="."/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:collectiveTitle">
                    <dt>Collection Title</dt>
                    <dd>
                      <xsl:value-of select="."/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:otherCitationDetails">
                    <dt>Other Citation Details</dt>
                    <dd>
                      <xsl:value-of select="."/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:series/gmd:CI_Series">
                    <dt>Series</dt>
                    <dd>
                      <dl>
                        <dd>
                          <dt>Series Title</dt>
                          <dd>
                            <xsl:value-of select="gmd:name"/>
                          </dd>
                          <dt>Issue</dt>
                          <dd>
                            <xsl:value-of select="gmd:issueIdentification"/>
                          </dd>
                        </dd>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
              <dt>Abstract</dt>
              <dd>
                <xsl:value-of select="."/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:purpose">
              <dt>Purpose</dt>
              <dd>
                <xsl:value-of select="."/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:supplementalInformation">
              <dt>Supplemental Information</dt>
              <dd>
                <xsl:value-of select="."/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator">
              <dt>Scale Denominator</dt>
              <dd>
                <xsl:value-of select="."/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent">
              <dt>Temporal Extent</dt>
              <dd>
                <dl>
                  <xsl:if test="ancestor-or-self::*/gmd:description">
                    <dt>Currentness Reference</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:description"/>
                    </dd>
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="gml:TimePeriod">
                      <dt>Time Period</dt>
                      <dd>
                        <dl>
                          <dt>Begin</dt>
                          <dd>
                            <xsl:value-of select="gml:TimePeriod/gml:beginPosition"/>
                          </dd>
                          <dt>End</dt>
                          <dd>
                            <xsl:value-of select="gml:TimePeriod/gml:endPosition"/>
                          </dd>
                        </dl>
                      </dd>
                    </xsl:when>
                    <xsl:when test="gml:TimeInstant">
                      <dt>Time Instant</dt>
                      <dd>
                        <xsl:value-of select="gml:TimeInstant/gml:timePosition"/>
                      </dd>
                    </xsl:when>
                  </xsl:choose>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
              <dt>Bounding Box</dt>
              <dd>
                <dl>
                  <dt>West</dt>
                  <dd>
                    <xsl:value-of select="gmd:westBoundLongitude"/>
                  </dd>
                  <dt>East</dt>
                  <dd>
                    <xsl:value-of select="gmd:eastBoundLongitude"/>
                  </dd>
                  <dt>North</dt>
                  <dd>
                    <xsl:value-of select="gmd:northBoundLatitude"/>
                  </dd>
                  <dt>South</dt>
                  <dd>
                    <xsl:value-of select="gmd:southBoundLatitude"/>
                  </dd>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
              <dt>ISO Topic Category</dt>
              <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
                <dd>
                  <xsl:value-of select="."/>
                </dd>
              </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords">
              <xsl:choose>
                <xsl:when test="ancestor-or-self::*/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='theme']">
                  <dt>Theme Keyword</dt>
                  <xsl:for-each select="gmd:keyword">
                    <dd>
                      <xsl:value-of select="."/>
                      <xsl:if test="position()=last()">
                        <dl>
                          <dt>Theme Keyword Thesaurus</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:thesaurusName/gmd:CI_Citation/gmd:title"/>
                          </dd>
                        </dl>
                      </xsl:if>
                    </dd>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="ancestor-or-self::*/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='place']">
                  <dt>Place Keyword</dt>
                  <xsl:for-each select="gmd:keyword">
                    <dd>
                      <xsl:value-of select="."/>
                      <xsl:if test="position()=last()">
                        <dl>
                          <dt>Place Keyword Thesaurus</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:thesaurusName/gmd:CI_Citation/gmd:title"/>
                          </dd>
                        </dl>
                      </xsl:if>
                    </dd>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="ancestor-or-self::*/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='temporal']">
                  <dt>Temporal Keyword</dt>
                  <xsl:for-each select="gmd:keyword">
                    <dd>
                      <xsl:value-of select="."/>
                    </dd>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints">
              <xsl:if test="gmd:MD_LegalConstraints">
                <dt>Legal Constraints</dt>
              </xsl:if>
              <xsl:if test="gmd:MD_SecurityConstraints">
                <dt>Security Constraints</dt>
              </xsl:if>
              <xsl:if test="gmd:MD_Constraints">
                <dt>Resource Constraints</dt>
              </xsl:if>
              <dd>
                <dl>
                  <xsl:if test="*/gmd:useLimitation">
                    <dt>Use Limitation</dt>
                    <dd>
                      <xsl:value-of select="*/gmd:useLimitation"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="*/gmd:accessConstraints">
                    <dt>Access Restrictions</dt>
                    <dd>
                      <xsl:value-of select="*/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="*/gmd:useConstraints">
                    <dt>Use Restrictions</dt>
                    <dd>
                      <xsl:value-of select="*/gmd:useConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="*/gmd:otherConstraints">
                    <dt>Other Restrictions</dt>
                    <dd>
                      <xsl:value-of select="*/gmd:otherConstraints"/>
                    </dd>
                  </xsl:if>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:status">
              <dt>Status</dt>
              <dd>
                <xsl:value-of select="gmd:MD_ProgressCode/@codeListValue"/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
              <dt>Maintenance and Update Frequency</dt>
              <dd>
                <xsl:value-of select="gmd:MD_MaintenanceFrequencyCode/@codeListValue"/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='largerWorkCitation']">
              <dt>Collection</dt>
              <dd>
                <dl>
                  <dt>Collection Title</dt>
                  <dd>
                    <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title"/>
                  </dd>
                  <dt>URL</dt>
                  <dd>
                    <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
                  </dd>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
                    <dt>Originator</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='publisher']">
                    <dt>Publisher</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:date">
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'publication')">
                      <dt>Publication Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'creation')">
                      <dt>Creation Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'revision')">
                      <dt>Revision Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:series/gmd:CI_Series">
                    <dt>Series</dt>
                    <dd>
                      <dl>
                        <dd>
                          <dt>Series Title</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:name"/>
                          </dd>
                          <dt>Issue</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:issueIdentification"/>
                          </dd>
                        </dd>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='crossReference']">
              <dt>Cross Reference</dt>
              <dd>
                <dl>
                  <dt>Title</dt>
                  <dd>
                    <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title"/>
                  </dd>
                  <dt>URL</dt>
                  <dd>
                    <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
                  </dd>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
                    <dt>Originator</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='publisher']">
                    <dt>Publisher</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:date">
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'publication')">
                      <dt>Publication Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'creation')">
                      <dt>Creation Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="contains(descendant-or-self::*/gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'revision')">
                      <dt>Revision Date</dt>
                      <dd>
                        <xsl:value-of select="gmd:CI_Date/gmd:date"/>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <dt>Language</dt>
            <dd>
              <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language"/>
            </dd>
            <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit">
              <dt>Credit</dt>
              <dd>
                <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:credit"/>
              </dd>
            </xsl:if>
            <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:pointOfContact">
              <dt>Point of Contact</dt>
              <dd>
                <dl>
                  <xsl:for-each select="gmd:CI_ResponsibleParty">
                    <dt>Contact</dt>
                    <dd>
                      <xsl:value-of select="gmd:organisationName | gmd:individualName"/>
                    </dd>
                    <xsl:if test="gmd:positionName">
                      <dt>Position Name</dt>
                      <dd>
                        <xsl:value-of select="gmd:positionName"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
                      <dt>Delivery Point</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city">
                      <dt>City</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea">
                      <dt>Administrative Area</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode">
                      <dt>Postal Code</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country">
                      <dt>Country</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                      <dt>Email</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
                      <dt>Phone</dt>
                      <dd>
                        <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice"/>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
    <!-- Spatial Reference Info -->
    <xsl:if test="gmd:referenceSystemInfo">
      <div id="iso-spatial-reference-info">
        <dt>Spatial Reference Information</dt>
        <dd>
          <dl>
            <dt>Reference System Identifier</dt>
            <dd>
              <dl>
                <dt>Code</dt>
                <dd>
                  <xsl:value-of select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code"/>
                </dd>
                <dt>Code Space</dt>
                <dd>
                  <xsl:value-of select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace"/>
                </dd>
                <dt>Version</dt>
                <dd>
                  <xsl:value-of select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:version"/>
                </dd>
              </dl>
            </dd>
          </dl>
        </dd>
      </div>
    </xsl:if>
    <!-- Data Quality Info -->
    <xsl:if test="gmd:dataQualityInfo/gmd:DQ_DataQuality">
      <div id="iso-data-quality-info">
        <dt>Data Quality Information</dt>
        <dd>
          <dl>
            <xsl:if test="gmd:DQ_Scope/gmd:level">
              <dt>Hierarchy Level</dt>
              <dd>
                <xsl:value-of select="gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode[@codeListValue]"/>
              </dd>
            </xsl:if>
            <xsl:for-each select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report">
              <xsl:if test="gmd:DQ_QuantitativeAttributeAccuracy">
                <dt>Quantitative Attribute Accuracy Report</dt>
                <dd>
                  <dl>
                    <xsl:if test="gmd:DQ_QuantitativeAttributeAccuracy/gmd:evaluationMethodDescription/text()">
                      <dt>Evaluation Method</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_QuantitativeAttributeAccuracy/gmd:evaluationMethodDescription"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:DQ_QuantitativeAttributeAccuracy/gmd:result/text()">
                      <dt>Result</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_QuantitativeAttributeAccuracy/gmd:result"/>
                      </dd>
                    </xsl:if>
                  </dl>
                </dd>
              </xsl:if>
              <xsl:if test="gmd:DQ_AbsoluteExternalPositionalAccuracy">
                <dt>Absolute External Positional Accuracy</dt>
                <dd>
                  <dl>
                    <xsl:if test="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:evaluationMethodDescription/text()">
                      <dt>Evaluation Method</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:evaluationMethodDescription"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:result/text()">
                      <dt>Result</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:result"/>
                      </dd>
                    </xsl:if>
                  </dl>
                </dd>
              </xsl:if>
              <xsl:if test="gmd:DQ_CompletenessCommission">
                <dt>Completeness Commission</dt>
                <dd>
                  <dl>
                    <xsl:if test="gmd:DQ_CompletenessCommission/gmd:evaluationMethodDescription/text()">
                      <dt>Evaluation Method</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_CompletenessCommission/gmd:evaluationMethodDescription"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:DQ_CompletenessCommission/gmd:result/text()">
                      <dt>Result</dt>
                      <dd>
                        <xsl:value-of select="gmd:DQ_CompletenessCommission/gmd:result"/>
                      </dd>
                    </xsl:if>
                  </dl>
                </dd>
              </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage">
              <dt>Lineage</dt>
              <dd>
                <dl>
                  <xsl:if test="gmd:statement">
                    <dt>Statement</dt>
                    <dd>
                      <xsl:value-of select="gmd:statement"/>
                    </dd>
                  </xsl:if>
                  <xsl:for-each select="gmd:processStep/gmd:LI_ProcessStep">
                    <dt>Process Step</dt>
                    <dd>
                      <dl>
                        <xsl:if test="gmd:description">
                          <dt>Description</dt>
                          <dd>
                            <xsl:value-of select="gmd:description"/>
                          </dd>
                        </xsl:if>
                        <xsl:for-each select="gmd:CI_ResponsibleParty">
                          <dt>Processor</dt>
                          <dd>
                            <xsl:value-of select="gmd:individualName | gmd:organisationName"/>
                          </dd>
                        </xsl:for-each>
                        <xsl:if test="gmd:dateTime">
                          <dt>Process Date</dt>
                          <dd>
                            <xsl:value-of select="gmd:dateTime"/>
                          </dd>
                        </xsl:if>
                      </dl>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:source/gmd:LI_Source/gmd:sourceCitation">
                    <dt>Source</dt>
                    <dd>
                      <dl>
                        <dt>Title</dt>
                        <dd>
                          <xsl:value-of select="gmd:CI_Citation/gmd:title"/>
                        </dd>
                        <xsl:for-each select="gmd:CI_Citation/gmd:date/gmd:CI_Date">
                          <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'publication')">
                            <dt>Publication Date</dt>
                            <dd>
                              <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                            </dd>
                          </xsl:if>
                          <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'creation')">
                            <dt>Creation Date</dt>
                            <dd>
                              <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                            </dd>
                          </xsl:if>
                          <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'revision')">
                            <dt>Revision Date</dt>
                            <dd>
                              <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                            </dd>
                          </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
                          <dt>Originator</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='publisher']">
                          <dt>Publisher</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:organisationName | ancestor-or-self::*/gmd:individualName"/>
                          </dd>
                          <xsl:if test="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city">
                            <dt>Place of Publication</dt>
                            <dd>
                              <xsl:value-of select="ancestor-or-self::*/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city"/>
                            </dd>
                          </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code">
                          <dt>Identifier</dt>
                          <dd>
                            <xsl:value-of select="gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
                          </dd>
                        </xsl:if>
                        <xsl:if test="ancestor-or-self::*/gmd:description">
                          <dt>Description</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:description"/>
                          </dd>
                        </xsl:if>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </div>
    </xsl:if>
    <!-- Distribution -->
    <xsl:if test="gmd:distributionInfo">
      <div id="iso-distribution-info">
        <dt>Distribution Information</dt>
        <dd>
          <dl>
            <xsl:if test="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format">
              <dt>Format Name</dt>
              <dd>
                <xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name"/>
              </dd>
              <xsl:if test="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:version/text()">
                <dt>Format Version</dt>
                <dd>
                  <xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:version"/>
                </dd>
              </xsl:if>
            </xsl:if>
            <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor">
              <dt>Distributor</dt>
              <dd>
                <xsl:value-of select="gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName"/>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions">
              <dt>Online Access</dt>
              <dd>
                <xsl:value-of select="gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL"/>
              </dd>
              <dt>Protocol</dt>
              <dd>
                <xsl:value-of select="gmd:onLine/gmd:CI_OnlineResource/gmd:protocol"/>
              </dd>
              <dt>Name</dt>
              <dd>
                <xsl:value-of select="gmd:onLine/gmd:CI_OnlineResource/gmd:name"/>
              </dd>
              <xsl:if test="gmd:onLine/gmd:CI_OnlineResource/gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue">
                <dt>Function</dt>
                <dd>
                  <xsl:value-of select="gmd:onLine/gmd:CI_OnlineResource/gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue"/>
                </dd>
              </xsl:if>
              <xsl:if test="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:transferSize">
                <dt>Transfer Size</dt>
                <dd>
                  <xsl:value-of select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:transferSize"/>
                </dd>
              </xsl:if>
            </xsl:for-each>
          </dl>
        </dd>
      </div>
    </xsl:if>
    <!-- Content Info -->
    <xsl:if test="gmd:contentInfo">
      <div id="iso-content-info">
        <dt>Content Information</dt>
        <dd>
          <dl>
            <xsl:if test="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
              <dt>Feature Catalog Description</dt>
              <dd>
                <dl>
                  <dt>Compliance Code</dt>
                  <dd>
                    <xsl:value-of select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:complianceCode"/>
                  </dd>
                  <dt>Language</dt>
                  <dd>
                    <xsl:value-of select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:language"/>
                  </dd>
                  <dt>Included With Dataset</dt>
                  <dd>
                    <xsl:value-of select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:includedWithDataset"/>
                  </dd>
                  <dt>Feature Catalog Citation</dt>
                  <dd>
                    <dl>
                      <dt>Title</dt>
                      <dd>
                        <xsl:value-of select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation/gmd:CI_Citation/gmd:title"/>
                      </dd>
                      <xsl:for-each select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation/gmd:CI_Citation/gmd:date/gmd:CI_Date">
                        <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'publication')">
                          <dt>Publication Date</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                          </dd>
                        </xsl:if>
                        <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'creation')">
                          <dt>Creation Date</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                          </dd>
                        </xsl:if>
                        <xsl:if test="contains(gmd:dateType/gmd:CI_DateTypeCode/@codeListValue,'revision')">
                          <dt>Revision Date</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/gmd:date/gmd:CI_Date/gmd:date"/>
                          </dd>
                        </xsl:if>
                      </xsl:for-each>
                      <dt>Feature Catalog Identifier</dt>
                      <dd>
                        <xsl:value-of select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
                      </dd>
                    </dl>
                  </dd>
                </dl>
              </dd>
            </xsl:if>
            <xsl:if test="gmd:contentInfo/gmd:MD_ImageDescription">
              <dt>Content Type</dt>
              <dd>
                <xsl:value-of select="gmd:contentInfo/gmd:MD_ImageDescription/gmd:contentType/gmd:MD_CoverageContentTypeCode[@codeListValue]"/>
              </dd>
            </xsl:if>
          </dl>
        </dd>
      </div>
    </xsl:if>
    <!-- Spatial Representation -->
    <xsl:if test="gmd:spatialRepresentationInfo">
      <div id="iso-spatial-representation-info">
        <dt>Spatial Representation Information</dt>
        <dd>
          <dl>
            <xsl:choose>
              <xsl:when test="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation">
                <dt>Vector</dt>
                <dd>
                  <dl>
                    <dt>Topology Level</dt>
                    <dd>
                      <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:topologyLevel/gmd:MD_TopologyLevelCode[@codeListValue]"/>
                    </dd>
                    <dt>Vector Object Type</dt>
                    <dd>
                      <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode[@codeListValue]"/>
                    </dd>
                    <dt>Vector Object Count</dt>
                    <dd>
                      <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectCount"/>
                    </dd>
                  </dl>
                </dd>
              </xsl:when>
              <xsl:when test="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation">
                <dt>Raster</dt>
                <dd>
                  <dl>
                    <xsl:if test="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation/gmd:numberOfDimensions">
                      <dt>Number of Dimensions</dt>
                      <dd>
                        <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation/gmd:numberOfDimensions"/>
                      </dd>
                    </xsl:if>
                    <dd>
                      <dl>
                        <xsl:for-each select="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:axisDimensionProperties/gmd:MD_Dimension">
                          <xsl:if test="gmd:dimensionName/gmd:MD_DimensionNameTypeCode/@codeListValue='column'">
                            <dt>Column Count</dt>
                            <dd>
                              <xsl:value-of select="gmd:dimensionSize"/>
                            </dd>
                          </xsl:if>
                          <xsl:if test="gmd:dimensionName/gmd:MD_DimensionNameTypeCode/@codeListValue='row'">
                            <dt>Row Count</dt>
                            <dd>
                              <xsl:value-of select="gmd:dimensionSize"/>
                            </dd>
                          </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:cellGeometry/gmd:MD_CellGeometryCode">
                          <dt>Cell Geometry Type</dt>
                          <dd>
                            <xsl:value-of select="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:cellGeometry/gmd:MD_CellGeometryCode/@codeListValue"/>
                          </dd>
                        </xsl:if>
                        <xsl:if test="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:cornerPoints">
                          <dt>Corner Points</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:cornerPoints/gml:Point">
                                <dt>Point</dt>
                                <dd>
                                  <xsl:value-of select="gml:pos"/>
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                          <xsl:for-each select="gmd:spatialRepresentationInfo/MD_GridSpatialRepresentation/gmd:centerPoint/gml:Point">
                            <dt>Center Point</dt>
                            <dd>
                              <xsl:value-of select="gml:pos"/>
                            </dd>
                          </xsl:for-each>
                        </xsl:if>
                      </dl>
                    </dd>
                  </dl>
                </dd>
              </xsl:when>
              <xsl:when test="gmd:spatialRepresentationInfo/gmd:MD_Georectified">
                <dt>Raster</dt>
                <dd>
                  <dl>
                    <xsl:if test="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:numberOfDimensions">
                      <dt>Number of Dimensions</dt>
                      <dd>
                        <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:numberOfDimensions"/>
                      </dd>
                    </xsl:if>
                    <xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:axisDimensionProperties/gmd:MD_Dimension">
                      <xsl:if test="gmd:dimensionName/gmd:MD_DimensionNameTypeCode/@codeListValue='column'">
                        <dt>Column Count</dt>
                        <dd>
                          <xsl:value-of select="gmd:dimensionSize"/>
                        </dd>
                      </xsl:if>
                      <xsl:if test="gmd:dimensionName/gmd:MD_DimensionNameTypeCode/@codeListValue='row'">
                        <dt>Row Count</dt>
                        <dd>
                          <xsl:value-of select="gmd:dimensionSize"/>
                        </dd>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:cellGeometry/gmd:MD_CellGeometryCode">
                      <dt>Cell Geometry Type</dt>
                      <dd>
                        <xsl:value-of select="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:cellGeometry/gmd:MD_CellGeometryCode/@codeListValue"/>
                      </dd>
                    </xsl:if>
                    <xsl:if test="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:cornerPoints">
                      <dt>Corner Points</dt>
                      <dd>
                        <dl>
                          <xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:cornerPoints/gml:Point">
                            <dt>Point</dt>
                            <dd>
                              <xsl:value-of select="gml:pos"/>
                            </dd>
                          </xsl:for-each>
                        </dl>
                      </dd>
                      <xsl:for-each select="gmd:spatialRepresentationInfo/gmd:MD_Georectified/gmd:centerPoint/gml:Point">
                        <dt>Center Point</dt>
                        <dd>
                          <xsl:value-of select="gml:pos"/>
                        </dd>
                      </xsl:for-each>
                    </xsl:if>
                  </dl>
                </dd>
              </xsl:when>
            </xsl:choose>
          </dl>
        </dd>
      </div>
    </xsl:if>
    <!-- Metadata Reference Info -->
    <div id="iso-metadata-reference-info">
      <dt>Metadata Reference Information</dt>
      <dd>
        <dl>
          <dt>Hierarchy Level</dt>
          <dd>
            <xsl:value-of select="gmd:hierarchyLevelName"/>
          </dd>
          <dt>Metadata File Identifier</dt>
          <dd>
            <xsl:value-of select="gmd:fileIdentifier"/>
          </dd>
          <xsl:if test="gmd:parentIdentifier">
            <dt>Parent Identifier</dt>
            <dd>
              <xsl:value-of select="gmd:parentIdentifier"/>
            </dd>
          </xsl:if>
          <xsl:if test="gmd:dataSetURI">
            <dt>Dataset URI</dt>
            <dd>
              <xsl:value-of select="gmd:dataSetURI"/>
            </dd>
          </xsl:if>
          <xsl:for-each select="gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:contact">
            <dt>Metadata Point of Contact</dt>
            <dd>
              <dl>
                <xsl:for-each select="gmd:CI_ResponsibleParty">
                  <dt>Name</dt>
                  <dd>
                    <xsl:value-of select="gmd:organisationName | gmd:individualName"/>
                  </dd>
                  <xsl:if test="gmd:positionName">
                    <dt>Position Name</dt>
                    <dd>
                      <xsl:value-of select="gmd:positionName"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint">
                    <dt>Delivery Point</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city">
                    <dt>City</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea">
                    <dt>Administrative Area</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode">
                    <dt>Postal Code</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country">
                    <dt>Country</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                    <dt>Email</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
                    </dd>
                  </xsl:if>
                  <xsl:if test="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
                    <dt>Phone</dt>
                    <dd>
                      <xsl:value-of select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice"/>
                    </dd>
                  </xsl:if>
                </xsl:for-each>
              </dl>
            </dd>
          </xsl:for-each>
          <dt>Metadata Date Stamp</dt>
          <dd>
            <xsl:value-of select="gmd:dateStamp"/>
          </dd>
          <dt>Metadata Standard Name</dt>
          <dd>
            <xsl:value-of select="gmd:metadataStandardName"/>
          </dd>
          <dt>Metadata Standard Version</dt>
          <dd>
            <xsl:value-of select="gmd:metadataStandardVersion"/>
          </dd>
          <xsl:if test="gmd:characterSet/gmd:MD_CharacterSetCode[@codeListValue]/text()">
            <dt>Character Set</dt>
            <dd>
              <xsl:value-of select="gmd:characterSet/gmd:MD_CharacterSetCode[@codeListValue]"/>
            </dd>
          </xsl:if>
        </dl>
      </dd>
    </div>
  </xsl:template>
</xsl:stylesheet>
