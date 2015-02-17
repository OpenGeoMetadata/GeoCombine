module XmlDocs

  ##
  # Example XSLT from https://developer.mozilla.org/en-US/docs/XSLT_in_Gecko/Basic_Example
  def simple_xslt
    <<-xml
      <?xml version="1.0"?>
        <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

        <xsl:output method="text"/>

        <xsl:template match="/">
          Article - <xsl:value-of select="/Article/Title"/>
          Authors: <xsl:apply-templates select="/Article/Authors/Author"/>
        </xsl:template>

        <xsl:template match="Author">
          - <xsl:value-of select="." />
        </xsl:template>

        </xsl:stylesheet>
    xml
  end

  ##
  # Example XML from https://developer.mozilla.org/en-US/docs/XSLT_in_Gecko/Basic_Example
  def simple_xml
    <<-xml
      <?xml version="1.0"?>
      <?xml-stylesheet type="text/xsl" href="example.xsl"?>
      <Article>
        <Title>My Article</Title>
        <Authors>
          <Author>Mr. Foo</Author>
          <Author>Mr. Bar</Author>
        </Authors>
        <Body>This is my article text.</Body>
      </Article>
    xml
  end

  ##
  # Stanford ISO19139 example record from https://github.com/OpenGeoMetadata/edu.stanford.purl/blob/08085d766014ea91e5defb6d172e5633bfd9b1ce/bb/338/jh/0716/iso19139.xml
  def stanford_iso
    <<-xml
      <MD_Metadata xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <fileIdentifier>
          <gco:CharacterString>edu.stanford.purl:bb338jh0716</gco:CharacterString>
        </fileIdentifier>
        <language>
          <LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="eng" codeSpace="ISO639-2">eng</LanguageCode>
        </language>
        <characterSet>
          <MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8" codeSpace="ISOTC211/19115">utf8</MD_CharacterSetCode>
        </characterSet>
        <parentIdentifier>
          <gco:CharacterString>http://purl.stanford.edu/zt526qk7324.mods</gco:CharacterString>
        </parentIdentifier>
        <hierarchyLevel>
          <MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset" codeSpace="ISOTC211/19115">dataset</MD_ScopeCode>
        </hierarchyLevel>
        <hierarchyLevelName>
          <gco:CharacterString>dataset</gco:CharacterString>
        </hierarchyLevelName>
        <contact>
          <CI_ResponsibleParty>
            <organisationName>
              <gco:CharacterString>Stanford Geospatial Center</gco:CharacterString>
            </organisationName>
            <positionName>
              <gco:CharacterString>Metadata Analyst</gco:CharacterString>
            </positionName>
            <contactInfo>
              <CI_Contact>
                <phone>
                  <CI_Telephone>
                    <voice>
                      <gco:CharacterString>650-723-2746</gco:CharacterString>
                    </voice>
                  </CI_Telephone>
                </phone>
                <address>
                  <CI_Address>
                    <deliveryPoint>
                      <gco:CharacterString>Branner Earth Sciences Library</gco:CharacterString>
                    </deliveryPoint>
                    <deliveryPoint>
                      <gco:CharacterString>Mitchell Bldg. 2nd floor</gco:CharacterString>
                    </deliveryPoint>
                    <deliveryPoint>
                      <gco:CharacterString>397 Panama Mall</gco:CharacterString>
                    </deliveryPoint>
                    <city>
                      <gco:CharacterString>Stanford</gco:CharacterString>
                    </city>
                    <administrativeArea>
                      <gco:CharacterString>California</gco:CharacterString>
                    </administrativeArea>
                    <postalCode>
                      <gco:CharacterString>94305</gco:CharacterString>
                    </postalCode>
                    <country>
                      <gco:CharacterString>US</gco:CharacterString>
                    </country>
                    <electronicMailAddress>
                      <gco:CharacterString>brannerlibrary@stanford.edu</gco:CharacterString>
                    </electronicMailAddress>
                  </CI_Address>
                </address>
              </CI_Contact>
            </contactInfo>
            <role>
              <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact" codeSpace="ISOTC211/19115">pointOfContact</CI_RoleCode>
            </role>
          </CI_ResponsibleParty>
        </contact>
        <dateStamp>
          <gco:Date>2014-10-08</gco:Date>
        </dateStamp>
        <metadataStandardName>
          <gco:CharacterString>ISO 19139 Geographic Information - Metadata - Implementation Specification</gco:CharacterString>
        </metadataStandardName>
        <metadataStandardVersion>
          <gco:CharacterString>2007</gco:CharacterString>
        </metadataStandardVersion>
        <dataSetURI>
          <gco:CharacterString>http://purl.stanford.edu/bb338jh0716</gco:CharacterString>
        </dataSetURI>
        <spatialRepresentationInfo>
          <MD_VectorSpatialRepresentation>
            <topologyLevel>
              <MD_TopologyLevelCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_TopologyLevelCode" codeListValue="geometryOnly" codeSpace="ISOTC211/19115">geometryOnly</MD_TopologyLevelCode>
            </topologyLevel>
            <geometricObjects>
              <MD_GeometricObjects>
                <geometricObjectType>
                  <MD_GeometricObjectTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_GeometricObjectTypeCode" codeListValue="composite" codeSpace="ISOTC211/19115">composite</MD_GeometricObjectTypeCode>
                </geometricObjectType>
                <geometricObjectCount>
                  <gco:Integer>11</gco:Integer>
                </geometricObjectCount>
              </MD_GeometricObjects>
            </geometricObjects>
          </MD_VectorSpatialRepresentation>
        </spatialRepresentationInfo>
        <referenceSystemInfo>
          <MD_ReferenceSystem>
            <referenceSystemIdentifier>
              <RS_Identifier>
                <code>
                  <gco:CharacterString>26910</gco:CharacterString>
                </code>
                <codeSpace>
                  <gco:CharacterString>EPSG</gco:CharacterString>
                </codeSpace>
                <version>
                  <gco:CharacterString>8.2.6</gco:CharacterString>
                </version>
              </RS_Identifier>
            </referenceSystemIdentifier>
          </MD_ReferenceSystem>
        </referenceSystemInfo>
        <identificationInfo>
          <MD_DataIdentification>
            <citation>
              <CI_Citation>
                <title>
                  <gco:CharacterString>Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999</gco:CharacterString>
                </title>
                <date>
                  <CI_Date>
                    <date>
                      <gco:Date>2002-09-01</gco:Date>
                    </date>
                    <dateType>
                      <CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication" codeSpace="ISOTC211/19115">publication</CI_DateTypeCode>
                    </dateType>
                  </CI_Date>
                </date>
                <identifier>
                  <MD_Identifier>
                    <code>
                      <gco:CharacterString>http://purl.stanford.edu/bb338jh0716</gco:CharacterString>
                    </code>
                  </MD_Identifier>
                </identifier>
                <citedResponsibleParty>
                  <CI_ResponsibleParty>
                    <organisationName>
                      <gco:CharacterString>Circuit Rider Productions</gco:CharacterString>
                    </organisationName>
                    <role>
                      <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="originator" codeSpace="ISOTC211/19115">originator</CI_RoleCode>
                    </role>
                  </CI_ResponsibleParty>
                </citedResponsibleParty>
                <citedResponsibleParty>
                  <CI_ResponsibleParty>
                    <organisationName>
                      <gco:CharacterString>Circuit Rider Productions</gco:CharacterString>
                    </organisationName>
                    <contactInfo>
                      <CI_Contact>
                        <address>
                          <CI_Address>
                            <city>
                              <gco:CharacterString>Windsor</gco:CharacterString>
                            </city>
                            <administrativeArea>
                              <gco:CharacterString>California</gco:CharacterString>
                            </administrativeArea>
                            <country>
                              <gco:CharacterString>US</gco:CharacterString>
                            </country>
                            <electronicMailAddress>
                              <gco:CharacterString>info@circuitriderstudios.com</gco:CharacterString>
                            </electronicMailAddress>
                          </CI_Address>
                        </address>
                      </CI_Contact>
                    </contactInfo>
                    <role>
                      <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="publisher" codeSpace="ISOTC211/19115">publisher</CI_RoleCode>
                    </role>
                  </CI_ResponsibleParty>
                </citedResponsibleParty>
                <presentationForm>
                  <CI_PresentationFormCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_PresentationFormCode" codeListValue="mapDigital" codeSpace="ISOTC211/19115">mapDigital</CI_PresentationFormCode>
                </presentationForm>
                <collectiveTitle>
                  <gco:CharacterString>Russian River Watershed GIS</gco:CharacterString>
                </collectiveTitle>
              </CI_Citation>
            </citation>
            <abstract>
              <gco:CharacterString>This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC). </gco:CharacterString>
            </abstract>
            <purpose>
              <gco:CharacterString>This shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.</gco:CharacterString>
            </purpose>
            <credit>
              <gco:CharacterString>Circuit Rider Productions and National Oceanic and Atmospheric Administration (2002). Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999. Circuit Rider Productions.</gco:CharacterString>
            </credit>
            <status>
              <MD_ProgressCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ProgressCode" codeListValue="completed" codeSpace="ISOTC211/19115">completed</MD_ProgressCode>
            </status>
            <pointOfContact>
              <CI_ResponsibleParty>
                <organisationName>
                  <gco:CharacterString>Circuit Rider Productions, Inc. </gco:CharacterString>
                </organisationName>
                <positionName>
                  <gco:CharacterString>GIS Coordinator </gco:CharacterString>
                </positionName>
                <contactInfo>
                  <CI_Contact>
                    <phone>
                      <CI_Telephone>
                        <voice>
                          <gco:CharacterString>707.838.6641 </gco:CharacterString>
                        </voice>
                      </CI_Telephone>
                    </phone>
                    <address>
                      <CI_Address>
                        <deliveryPoint>
                          <gco:CharacterString>9619 Old Redwood Highway </gco:CharacterString>
                        </deliveryPoint>
                        <city>
                          <gco:CharacterString>Windsor</gco:CharacterString>
                        </city>
                        <administrativeArea>
                          <gco:CharacterString>California</gco:CharacterString>
                        </administrativeArea>
                        <postalCode>
                          <gco:CharacterString>95492 </gco:CharacterString>
                        </postalCode>
                        <country>
                          <gco:CharacterString>US</gco:CharacterString>
                        </country>
                      </CI_Address>
                    </address>
                  </CI_Contact>
                </contactInfo>
                <role>
                  <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact" codeSpace="ISOTC211/19115">pointOfContact</CI_RoleCode>
                </role>
              </CI_ResponsibleParty>
            </pointOfContact>
            <resourceMaintenance>
              <MD_MaintenanceInformation>
                <maintenanceAndUpdateFrequency>
                  <MD_MaintenanceFrequencyCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_MaintenanceFrequencyCode" codeListValue="notPlanned" codeSpace="ISOTC211/19115">notPlanned</MD_MaintenanceFrequencyCode>
                </maintenanceAndUpdateFrequency>
              </MD_MaintenanceInformation>
            </resourceMaintenance>
            <descriptiveKeywords>
              <MD_Keywords>
                <keyword>
                  <gco:CharacterString>Sonoma County (Calif.)</gco:CharacterString>
                </keyword>
                <keyword>
                  <gco:CharacterString>Mendocino County (Calif.)</gco:CharacterString>
                </keyword>
                <keyword>
                  <gco:CharacterString>Russian River Watershed (Calif.)</gco:CharacterString>
                </keyword>
                <type>
                  <MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="place" codeSpace="ISOTC211/19115">place</MD_KeywordTypeCode>
                </type>
                <thesaurusName>
                  <CI_Citation>
                    <title>
                      <gco:CharacterString>geonames</gco:CharacterString>
                    </title>
                    <date>
                      <CI_Date>
                        <date>
                          <gco:Date>2012-11-01</gco:Date>
                        </date>
                        <dateType>
                          <CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision" codeSpace="ISOTC211/19115">revision</CI_DateTypeCode>
                        </dateType>
                      </CI_Date>
                    </date>
                    <edition>
                      <gco:CharacterString>3.1</gco:CharacterString>
                    </edition>
                    <identifier>
                      <MD_Identifier>
                        <code>
                          <gco:CharacterString>http://www.geonames.org/ontology#</gco:CharacterString>
                        </code>
                      </MD_Identifier>
                    </identifier>
                  </CI_Citation>
                </thesaurusName>
              </MD_Keywords>
            </descriptiveKeywords>
            <descriptiveKeywords>
              <MD_Keywords>
                <keyword>
                  <gco:CharacterString>1999</gco:CharacterString>
                </keyword>
                <type>
                  <MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="temporal" codeSpace="ISOTC211/19115">temporal</MD_KeywordTypeCode>
                </type>
              </MD_Keywords>
            </descriptiveKeywords>
            <descriptiveKeywords>
              <MD_Keywords>
                <keyword>
                  <gco:CharacterString>Hydrology</gco:CharacterString>
                </keyword>
                <keyword>
                  <gco:CharacterString>Watersheds</gco:CharacterString>
                </keyword>
                <type>
                  <MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme" codeSpace="ISOTC211/19115">theme</MD_KeywordTypeCode>
                </type>
                <thesaurusName>
                  <CI_Citation>
                    <title>
                      <gco:CharacterString>lcsh</gco:CharacterString>
                    </title>
                    <date>
                      <CI_Date>
                        <date>
                          <gco:Date>2011-04-26</gco:Date>
                        </date>
                        <dateType>
                          <CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision" codeSpace="ISOTC211/19115">revision</CI_DateTypeCode>
                        </dateType>
                      </CI_Date>
                    </date>
                    <identifier>
                      <MD_Identifier>
                        <code>
                          <gco:CharacterString>http://id.loc.gov/authorities/subjects.html</gco:CharacterString>
                        </code>
                      </MD_Identifier>
                    </identifier>
                  </CI_Citation>
                </thesaurusName>
              </MD_Keywords>
            </descriptiveKeywords>
            <descriptiveKeywords>
              <MD_Keywords>
                <keyword>
                  <gco:CharacterString>Downloadable Data</gco:CharacterString>
                </keyword>
                <thesaurusName uuidref="723f6998-058e-11dc-8314-0800200c9a66"/>
              </MD_Keywords>
            </descriptiveKeywords>
            <resourceConstraints>
              <MD_LegalConstraints>
                <useLimitation>
                  <gco:CharacterString>No restrictions on access or use.</gco:CharacterString>
                </useLimitation>
              </MD_LegalConstraints>
            </resourceConstraints>
            <aggregationInfo>
              <MD_AggregateInformation>
                <aggregateDataSetName>
                  <CI_Citation>
                    <title>
                      <gco:CharacterString>Russian River Watershed GIS</gco:CharacterString>
                    </title>
                    <date>
                      <CI_Date>
                        <date>
                          <gco:Date>2002-10-24</gco:Date>
                        </date>
                        <dateType>
                          <CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication" codeSpace="ISOTC211/19115">publication</CI_DateTypeCode>
                        </dateType>
                      </CI_Date>
                    </date>
                    <identifier>
                      <MD_Identifier>
                        <code>
                          <gco:CharacterString>http://purl.stanford.edu/zt526qk7324</gco:CharacterString>
                        </code>
                      </MD_Identifier>
                    </identifier>
                    <citedResponsibleParty>
                      <CI_ResponsibleParty>
                        <organisationName>
                          <gco:CharacterString>Circuit Rider Productions</gco:CharacterString>
                        </organisationName>
                        <role>
                          <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="originator" codeSpace="ISOTC211/19115">originator</CI_RoleCode>
                        </role>
                      </CI_ResponsibleParty>
                    </citedResponsibleParty>
                    <citedResponsibleParty>
                      <CI_ResponsibleParty>
                        <organisationName>
                          <gco:CharacterString>Circuit Rider Productions</gco:CharacterString>
                        </organisationName>
                        <contactInfo>
                          <CI_Contact>
                            <address>
                              <CI_Address>
                                <city>
                                  <gco:CharacterString>Windsor</gco:CharacterString>
                                </city>
                                <administrativeArea>
                                  <gco:CharacterString>California</gco:CharacterString>
                                </administrativeArea>
                                <country>
                                  <gco:CharacterString>US</gco:CharacterString>
                                </country>
                                <electronicMailAddress>
                                  <gco:CharacterString>info@circuitriderstudios.com</gco:CharacterString>
                                </electronicMailAddress>
                              </CI_Address>
                            </address>
                          </CI_Contact>
                        </contactInfo>
                        <role>
                          <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="publisher" codeSpace="ISOTC211/19115">publisher</CI_RoleCode>
                        </role>
                      </CI_ResponsibleParty>
                    </citedResponsibleParty>
                    <citedResponsibleParty>
                      <CI_ResponsibleParty>
                        <organisationName>
                          <gco:CharacterString>United States. National Oceanic and Atmospheric Administration</gco:CharacterString>
                        </organisationName>
                        <role>
                          <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="originator" codeSpace="ISOTC211/19115">originator</CI_RoleCode>
                        </role>
                      </CI_ResponsibleParty>
                    </citedResponsibleParty>
                  </CI_Citation>
                </aggregateDataSetName>
                <associationType>
                  <DS_AssociationTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DS_AssociationTypeCode" codeListValue="largerWorkCitation" codeSpace="ISOTC211/19115">largerWorkCitation</DS_AssociationTypeCode>
                </associationType>
                <initiativeType>
                  <DS_InitiativeTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#DS_InitiativeTypeCode" codeListValue="collection" codeSpace="ISOTC211/19115">collection</DS_InitiativeTypeCode>
                </initiativeType>
              </MD_AggregateInformation>
            </aggregationInfo>
            <spatialRepresentationType>
              <MD_SpatialRepresentationTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_SpatialRepresentationTypeCode" codeListValue="vector" codeSpace="ISOTC211/19115">vector</MD_SpatialRepresentationTypeCode>
            </spatialRepresentationType>
            <language>
              <LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="eng" codeSpace="ISO639-2">eng</LanguageCode>
            </language>
            <characterSet>
              <MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8" codeSpace="ISOTC211/19115">utf8</MD_CharacterSetCode>
            </characterSet>
            <topicCategory>
              <MD_TopicCategoryCode>boundaries</MD_TopicCategoryCode>
            </topicCategory>
            <topicCategory>
              <MD_TopicCategoryCode>inlandWaters</MD_TopicCategoryCode>
            </topicCategory>
            <environmentDescription>
              <gco:CharacterString>Microsoft Windows 7 Version 6.1 (Build 7601) Service Pack 1; Esri ArcGIS 10.2.2.3552</gco:CharacterString>
            </environmentDescription>
            <extent>
              <EX_Extent>
                <description>
                  <gco:CharacterString>ground condition</gco:CharacterString>
                </description>
                <temporalElement>
                  <EX_TemporalExtent>
                    <extent>
                      <gml:TimePeriod gml:id="idp82864">
                        <gml:beginPosition>1999-01-01T00:00:00</gml:beginPosition>
                        <gml:endPosition>1999-12-31T00:00:00</gml:endPosition>
                      </gml:TimePeriod>
                    </extent>
                  </EX_TemporalExtent>
                </temporalElement>
              </EX_Extent>
            </extent>
            <extent>
              <EX_Extent>
                <geographicElement>
                  <EX_GeographicBoundingBox>
                    <extentTypeCode>
                      <gco:Boolean>true</gco:Boolean>
                    </extentTypeCode>
                    <westBoundLongitude>
                      <gco:Decimal>-123.387866</gco:Decimal>
                    </westBoundLongitude>
                    <eastBoundLongitude>
                      <gco:Decimal>-122.522658</gco:Decimal>
                    </eastBoundLongitude>
                    <southBoundLatitude>
                      <gco:Decimal>38.298024</gco:Decimal>
                    </southBoundLatitude>
                    <northBoundLatitude>
                      <gco:Decimal>39.399217</gco:Decimal>
                    </northBoundLatitude>
                  </EX_GeographicBoundingBox>
                </geographicElement>
              </EX_Extent>
            </extent>
          </MD_DataIdentification>
        </identificationInfo>
        <contentInfo>
          <MD_FeatureCatalogueDescription>
            <complianceCode>
              <gco:Boolean>false</gco:Boolean>
            </complianceCode>
            <language>
              <LanguageCode codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php" codeListValue="eng" codeSpace="ISO639-2">eng</LanguageCode>
            </language>
            <includedWithDataset>
              <gco:Boolean>true</gco:Boolean>
            </includedWithDataset>
            <featureCatalogueCitation>
              <CI_Citation>
                <title>
                  <gco:CharacterString>Feature Catalog for Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999</gco:CharacterString>
                </title>
                <date>
                  <CI_Date>
                    <date>
                      <gco:Date>2002-09-01</gco:Date>
                    </date>
                    <dateType>
                      <CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication" codeSpace="ISOTC211/19115">publication</CI_DateTypeCode>
                    </dateType>
                  </CI_Date>
                </date>
                <identifier>
                  <MD_Identifier>
                    <code>
                      <gco:CharacterString>476add9f-ea84-472c-a032-e6e8fd85337f</gco:CharacterString>
                    </code>
                  </MD_Identifier>
                </identifier>
                <citedResponsibleParty>
                  <CI_ResponsibleParty>
                    <organisationName>
                      <gco:CharacterString>Circuit Rider Productions</gco:CharacterString>
                    </organisationName>
                    <role>
                      <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="originator" codeSpace="ISOTC211/19115">originator</CI_RoleCode>
                    </role>
                  </CI_ResponsibleParty>
                </citedResponsibleParty>
              </CI_Citation>
            </featureCatalogueCitation>
          </MD_FeatureCatalogueDescription>
        </contentInfo>
        <distributionInfo>
          <MD_Distribution>
            <distributionFormat>
              <MD_Format>
                <name>
                  <gco:CharacterString>Shapefile</gco:CharacterString>
                </name>
                <version gco:nilReason="missing"/>
              </MD_Format>
            </distributionFormat>
            <distributor>
              <MD_Distributor>
                <distributorContact>
                  <CI_ResponsibleParty>
                    <organisationName>
                      <gco:CharacterString>Stanford Geospatial Center</gco:CharacterString>
                    </organisationName>
                    <contactInfo>
                      <CI_Contact>
                        <phone>
                          <CI_Telephone>
                            <voice>
                              <gco:CharacterString>650-723-2746</gco:CharacterString>
                            </voice>
                          </CI_Telephone>
                        </phone>
                        <address>
                          <CI_Address>
                            <deliveryPoint>
                              <gco:CharacterString>Mitchell Bldg. 2nd floor</gco:CharacterString>
                            </deliveryPoint>
                            <deliveryPoint>
                              <gco:CharacterString>397 Panama Mall</gco:CharacterString>
                            </deliveryPoint>
                            <city>
                              <gco:CharacterString>Stanford</gco:CharacterString>
                            </city>
                            <administrativeArea>
                              <gco:CharacterString>California</gco:CharacterString>
                            </administrativeArea>
                            <postalCode>
                              <gco:CharacterString>94305</gco:CharacterString>
                            </postalCode>
                            <country>
                              <gco:CharacterString>US</gco:CharacterString>
                            </country>
                            <electronicMailAddress>
                              <gco:CharacterString>brannerlibrary@stanford.edu</gco:CharacterString>
                            </electronicMailAddress>
                          </CI_Address>
                        </address>
                      </CI_Contact>
                    </contactInfo>
                    <role>
                      <CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="distributor" codeSpace="ISOTC211/19115">distributor</CI_RoleCode>
                    </role>
                  </CI_ResponsibleParty>
                </distributorContact>
              </MD_Distributor>
            </distributor>
            <transferOptions>
              <MD_DigitalTransferOptions>
                <transferSize>
                  <gco:Real>0.3</gco:Real>
                </transferSize>
                <onLine>
                  <CI_OnlineResource>
                    <linkage>
                      <URL>http://purl.stanford.edu/bb338jh0716</URL>
                    </linkage>
                    <protocol>
                      <gco:CharacterString>http</gco:CharacterString>
                    </protocol>
                    <name>
                      <gco:CharacterString>rr_cw22a_russ_hsa.shp</gco:CharacterString>
                    </name>
                    <function>
                      <CI_OnLineFunctionCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="download" codeSpace="ISOTC211/19115">download</CI_OnLineFunctionCode>
                    </function>
                  </CI_OnlineResource>
                </onLine>
              </MD_DigitalTransferOptions>
            </transferOptions>
          </MD_Distribution>
        </distributionInfo>
        <dataQualityInfo>
          <DQ_DataQuality>
            <scope>
              <DQ_Scope>
                <level>
                  <MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset" codeSpace="ISOTC211/19115">dataset</MD_ScopeCode>
                </level>
              </DQ_Scope>
            </scope>
            <lineage>
              <LI_Lineage>
                <statement>
                  <gco:CharacterString>RR_cw22a_russ_hsa.shp was developed by Colin Brooks (CDFG and IHRMP). This layer represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC). </gco:CharacterString>
                </statement>
              </LI_Lineage>
            </lineage>
          </DQ_DataQuality>
        </dataQualityInfo>
      </MD_Metadata>
    xml
  end

  ##
  # Example GeoBlacklight XML from 
  def stanford_geobl
    <<-xml
      <?xml version="1.0" encoding="UTF-8"?>
      <add xmlns="http://lucene.apache.org/solr/4/document">
      <doc>
        <field name="uuid">http://purl.stanford.edu/bb338jh0716</field>
        <field name="dc_identifier_s">http://purl.stanford.edu/bb338jh0716</field>
        <field name="dc_title_s">Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999</field>
        <field name="dc_description_s">This polygon dataset represents the Hydrologic Sub-Area boundaries for the Russian River basin, as defined by the Calwater 2.2a watershed boundaries. The original CALWATER22 layer (Calwater 2.2a watershed boundaries) was developed as a coverage named calw22a and is administered by the Interagency California Watershed Mapping Committee (ICWMC). This shapefile can be used to map and analyze data at the Hydrologic Sub-Area scale.</field>
        <field name="dc_rights_s">Restricted</field>
        <field name="dct_provenance_s">Stanford</field>
        <field name="dct_references_s">{"http://schema.org/url":"http://opengeometadata.stanford.edu/metadata/edu.stanford.purl/druid:bb338jh0716/default.html","http://www.loc.gov/mods/v3":"http://purl.stanford.edu/bb338jh0716.mods","http://www.isotc211.org/schemas/2005/gmd/":"http://opengeometadata.stanford.edu/metadata/edu.stanford.purl/druid:bb338jh0716/iso19139.xml","http://www.w3.org/1999/xhtml":"http://opengeometadata.stanford.edu/metadata/edu.stanford.purl/druid:bb338jh0716/default.html","http://www.opengis.net/def/serviceType/ogc/wfs":"https://geowebservices-restricted.stanford.edu/geoserver/wfs","http://www.opengis.net/def/serviceType/ogc/wms":"https://geowebservices-restricted.stanford.edu/geoserver/wms"}</field>
        <field name="layer_id_s">druid:bb338jh0716</field>
        <field name="layer_slug_s">stanford-bb338jh0716</field>
        <field name="layer_geom_type_s">Polygon</field>
        <field name="layer_modified_dt">2014-12-16T19:30:53Z</field>
        <field name="dc_format_s">Shapefile</field>
        <field name="dc_language_s">English</field>
        <field name="dc_type_s">Dataset</field>
        <field name="dc_publisher_s">Circuit Rider Productions</field>
        <field name="dc_creator_sm">Circuit Rider Productions</field>
        <field name="dc_subject_sm">Hydrology</field>
        <field name="dc_subject_sm">Watersheds</field>
        <field name="dc_subject_sm">Boundaries</field>
        <field name="dc_subject_sm">Inland Waters</field>
        <field name="dct_issued_s">2002</field>
        <field name="dct_temporal_sm">1999</field>
        <field name="dct_spatial_sm">Sonoma County (Calif.)</field>
        <field name="dct_spatial_sm">Mendocino County (Calif.)</field>
        <field name="dct_spatial_sm">Russian River Watershed (Calif.)</field>
        <field name="dc_relation_sm">http://sws.geonames.org/5397100/about.rdf</field>
        <field name="dc_relation_sm">http://sws.geonames.org/5372163/about.rdf</field>
        <field name="georss_box_s">38.298673 -123.387626 39.399103 -122.528843</field>
        <field name="georss_polygon_s">38.298673 -123.387626 39.399103 -123.387626 39.399103 -122.528843 38.298673 -122.528843 38.298673 -123.387626</field>
        <field name="solr_geom">ENVELOPE(-123.387626, -122.528843, 39.399103, 38.298673)</field>
        <field name="solr_bbox">-123.387626 38.298673 -122.528843 39.399103</field>
        <field name="solr_year_i">1999</field>
      </doc>
      </add>
    xml
  end

  ##
  # Example FGDC XML from https://github.com/OpenGeoMetadata/edu.tufts/blob/master/0/108/220/208/fgdc.xml
  def tufts_fgdc
    <<-xml
      <?xml version="1.0" encoding="utf-8" ?><!DOCTYPE metadata SYSTEM "http://www.fgdc.gov/metadata/fgdc-std-001-1998.dtd"><metadata>
        <idinfo>
          <citation>
            <citeinfo>
              <origin>Instituto Geografico Militar (Ecuador)</origin>
              <pubdate>2011</pubdate>
              <title>Drilling Towers 50k Scale Ecuador 2011</title>
              <geoform>vector digital data</geoform>
              <serinfo>
                <sername>Ecuador</sername>
              </serinfo>
              <pubinfo>
                <pubplace>Ecuador</pubplace>
                <publish>Instituto Geografico Militar (Ecuador)</publish>
              </pubinfo>
              <onlink>http://www.geoportaligm.gob.ec/portal/</onlink>
              <lworkcit>
                <citeinfo>
                  <origin>Instituto Geografico Militar (Ecuador)</origin>
                  <pubdate>2011</pubdate>
                  <title>Instituto Geografico Militar Data</title>
                  <pubinfo>
                    <pubplace>Ecuador</pubplace>
                    <publish>Instituto Geografico Militar (Ecuador)</publish>
                  </pubinfo>
                  <onlink>http://www.geoportaligm.gob.ec/portal/</onlink>
                </citeinfo>
              </lworkcit>
              <ftname Sync="TRUE">Ecuador50KDrillingTower11</ftname>
      </citeinfo>
          </citation>
          <descript>
            <abstract>This point dataset represents drilling towers in Ecuador created from 1:50,000 scale topographic maps.</abstract>
            <purpose>This dataset is intended for researchers, students, and policy makers for reference and mapping purposes, and may be used for basic applications such as viewing, querying, and map output production, or to provide a basemap to support graphical overlays and analysis with other spatial data.</purpose>
            <langdata Sync="TRUE">en</langdata>
      </descript>
          <timeperd>
            <timeinfo>
              <sngdate>
                <caldate>2011</caldate>
              </sngdate>
            </timeinfo>
            <current>publication date</current>
          </timeperd>
          <status>
            <progress>Complete</progress>
            <update>As needed</update>
          </status>
          <spdom>
            <bounding>
              <westbc>
      -79.904768</westbc>
              <eastbc>
      -79.904768</eastbc>
              <northbc>
      -1.377743</northbc>
              <southbc>
      -1.377743</southbc>
            </bounding>
            <lboundng>
      <leftbc Sync="TRUE">621844.388200</leftbc>
      <rightbc Sync="TRUE">621844.388200</rightbc>
      <bottombc Sync="TRUE">9847689.668600</bottombc>
      <topbc Sync="TRUE">9847689.668600</topbc>
      </lboundng>
      </spdom>
          <keywords>
            <theme>
              <themekt>FGDC</themekt>
              <themekey>point</themekey>
            </theme>
            <theme>
              <themekt>ISO 19115 Topic Category</themekt>
              <themekey>structure</themekey>
              <themekey>economy</themekey>
            </theme>
            <theme>
              <themekt>LCSH</themekt>
              <themekey>Drilling platforms</themekey>
              <themekey>Oil well drilling</themekey>
            </theme>
            <place>
              <placekt>GNS</placekt>
              <placekey>Ecuador</placekey>
              <placekey>República del Ecuador</placekey>
            </place>
            <place>
              <placekt>LCNH</placekt>
              <placekey>Northern Hemisphere</placekey>
              <placekey>Southern Hemisphere</placekey>
              <placekey>Western Hemisphere</placekey>
              <placekey>South America</placekey>
            </place>
          </keywords>
          <accconst>Unrestricted Access Online</accconst>
          <useconst>For educational noncommercial use only.</useconst>
          <ptcontac>
            <cntinfo>
              <cntorgp>
                <cntorg>Instituto Geografico Militar</cntorg>
              </cntorgp>
              <cntpos>Gestion Geografica- Gestion IDE</cntpos>
              <cntaddr>
                <addrtype>mailing and physical address</addrtype>
                <address>Senierges E4-676</address>
                <city>Sector el Dorado, Quito</city>
                <state>Pinchincha</state>
                <postal>17-01-2435</postal>
                <country>Ecuador</country>
              </cntaddr>
              <cntvoice>3975100 extension 129</cntvoice>
              <cntemail>nicolay.vaca@mail.igm.gob.ec</cntemail>
              <cntinst>Capt. Nicolay Vaca (Jefe Gestión Geográfica) nicolay.vaca@mail.igm.gob.ec

      Ing. Susana Arciniegas (Investigación y desarrollo) susana.arciniegas@mail.igm.gob.ec

      Ing. Miguel Ruano (Normalización)miguel.ruano@mail.igm.gob.ec

      Ing. Edison Bravo (Administrador de Contenidos Geográficos)edison.bravo@mail.igm.gob.ec

      Ing. Fernanda León (Administradora de Contenidos Geográficos)fernanda.leon@mail.igm.gob.ec

      Ing. Pablo Montenegro (Administrador de Aplicaciones Geoinformáticas)  pablo.montenegro@mail.igm.gob.ec

      Ing. Mauricio Albán (Administrador de Aplicaciones Geoinformáticas)mauricio.alban@mail.igm.gob.ec

      Ing. Xavier Vivas (Diseñador) xavier.vivas@mail.igm.gob.ec</cntinst>
            </cntinfo>
          </ptcontac>
          <native>Microsoft Windows Vista Version 6.1 (Build 7601) Service Pack 1; ESRI ArcCatalog 9.3.1.4000</native>
          <natvform Sync="TRUE">Shapefile</natvform>
      </idinfo>
        <dataqual>
          <lineage>
            <srcinfo>
              <srcscale>1:50,000</srcscale>
              <srccontr>Instituto Geografico Militar (Ecuador)</srccontr>
            </srcinfo>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>C:\Users\nsusma01\AppData\Local\Temp\\xmlEFBB.tmp</srcused>
              <procdate>20130212</procdate>
              <proctime>11073200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Starter Metadata Template -Tufts - UTF-8.xml</srcused>
              <procdate>20130708</procdate>
              <proctime>12383100</proctime>
            </procstep>
            <procstep>
              <procdesc>Name changed from torre_perforacion_p to Ecuador50KDrillingTower11</procdesc>
              <procdate>20130708</procdate>
              <proccont>
                <cntinfo>
                  <cntorgp>
                    <cntorg>Tufts University GIS Center</cntorg>
                  </cntorgp>
                  <cntpos>GIS Data Technician</cntpos>
                  <cntaddr>
                    <addrtype>mailing and physical address</addrtype>
                    <address>Academic Technology</address>
                    <address>16 Dearborn Ave</address>
                    <city>Somerville</city>
                    <state>MA</state>
                    <postal>02144</postal>
                    <country>USA</country>
                  </cntaddr>
                  <cntvoice>617-627-3380</cntvoice>
                  <cntemail>gis-support@elist.tufts.edu</cntemail>
                  <hours>Monday-Friday, 9:00 AM-5:00 PM, EST-USA</hours>
                </cntinfo>
              </proccont>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\IGMMetadata.xml</srcused>
              <procdate>20130708</procdate>
              <proctime>15510900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\acequia_l\EcuadorIrrigation12.shp.xml</srcused>
              <procdate>20130709</procdate>
              <proctime>09201900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\acueducto_a\EcuadorAqueducts11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>09400600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\aeropuerto_a\EcuadorAirports11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>11044900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\alcantarilla_p\EcuadorCulvert11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>11094800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\antena_parabolica_p\EcuadorSatelliteDish11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>11211000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\area_inundacion_a\EcuadorInundationArea11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>11315000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\arena_a\EcuadorArena11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>11501300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\arena_p\EcuadorArenaPt11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>12433800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\bocatoma_p\EcuadorWaterIntake11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>12513700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\bodega_p\EcuadorWarehouse11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>13510700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cable_aereo_l\EcuadorRailroad11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>14203000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\campamento_a\EcuadorTemporaryHousing11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>14490000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\campamento_militar_p\EcuadorMilitaryCamp11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>14551100</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\campamento_p\EcuadorTemporaryHousingPt11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>15085600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\campo_gas_a\EcuadorGasFields11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>15301900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cancha_a\EcuadorFields11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>15455200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cantera_a\EcuadorQuarries11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>16113800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\caracteristica_terreno_a\EcuadorSurfaceCover11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>16232300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\casa_a\EcuadorHouses11.shp.xml</srcused>
              <procdate>20130710</procdate>
              <proctime>16430800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cascada_l\EcuadorWaterfalls11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>09501700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cementerio_a\EcuadorCemetery11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>10112700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\central_electrica_a\EcuadorPowerPlants11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>10221000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\central_electrica_p\EcuadorPowerPlantsPoints11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>10282300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cerca_l\EcuadorFenceBoundaries11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>10495600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\choza_a\EcuadorHutsShacks11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>11030100</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\cienaga_a\EcuadorSwamps11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>11181500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\complejo_a\EcuadorEntertainment11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>11351900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\compuerta_p\EcuadorFloodGates11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>11470800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\comunidad_a\EcuadorIndigenousComm11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>11592500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\corral_a\EcuadorLivestock11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>12363900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\curva_batimetrica_l\EcuadorBathymetry11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>13051400</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\curva_nivel_l\EcuadorElevation11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>13143000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\duna_a\EcuadorSandDunes11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>13225500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\edificio_a\EcuadorBuildings11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>13452700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\embalse_a\EcuadorReservoir11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>13564600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\esclusa_l\EcuadorSluice11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>14081800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\establo_a\EcuadorStables11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>14194600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\estacion_a\EcuadorStation11.shp.xml</srcused>
              <procdate>20130711</procdate>
              <proctime>15354600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\estadio_a\EcuadorStadiums11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>12582700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\estrato_rocoso_a\EcuadorTerrain11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>13041600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\faro_p\EcuadorLighthouse11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>13233600</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\granjas_acuaticas_a\EcuadorFishFarm11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>13281900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\granjas_acuaticas_p\EcuadorFishFarmsPoints11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>13301300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\hacienda_a\EcuadorFarms11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>13464300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\helipuerto_p\EcuadorHelipuerts11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>15301800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\instalacion_militar_a\EcuadorMilitary11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>15375800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\instalacion_militar_p\EcuadorMilitaryPoints11.shp.xml</srcused>
              <procdate>20130712</procdate>
              <proctime>15523800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\instalaciones_petroliferas_a\EcuadorOilProduction11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>09151700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\isla_a\EcuadorIslands11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>09483400</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\linea_transmision_electrica_l\EcuadorElectricLines11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>10021800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\linea_tren_l\EcuadorRailLines11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>10260800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\malecon_l\EcuadorBreakwater11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>10374500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\manantial_p\EcuadorNaturalSpring11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>10560800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\mina_a\EcuadorMine11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>11242100</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\mirador_p\EcuadorViewpoint11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>11364200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\monumento_p\EcuadorMonuments11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>11452800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\muelle_a\EcuadorDocks11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>12500200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\muro_contencion_l\EcuadorRetainingWalls11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>12590400</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\muro_l\EcuadorWalls11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>13440800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\piscina_a\EcuadorPools11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>13532400</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\pista_aterrizaje_l\EcuadorRunways11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>14211000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\pista_carreras_a\RacetracksEquador11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>14354300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\planta_procesamiento_p\EcuadorProcessingPlant11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>15371800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\poblado_p\EcuadorCitiesTowns11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>15542200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\pozo_a\EcuadorLiqGasWell11.shp.xml</srcused>
              <procdate>20130715</procdate>
              <proctime>16164400</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\presa_a\EcuadorReservoirs11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>09464800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\procesamiento_residuos_a\EcuadorWaste11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>10323300</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\puente_l\EcuadorBridges11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>12163200</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\rio_a\EcuadorRiver11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>12242800</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\rio_l\EucadorRiversLine11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>12344000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\roca_a\EcuadorRocks11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>13280000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\ruta_ferry_l\EcuadorFerryRoute11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>13492900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\ruta_ferry_p\EcuadorFerryRoutePoint11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>14222500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\sin_informacion_a\EcuadorNoInfo11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>14275700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\sitio_arqueologico_a\EcuadorArchaeologicalSites11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>14375100</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\subestacion_a\EcuadorSubstations11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>15210500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\tanque_a\EcuadorTanks11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>15562900</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\terraplen_a\EcuadorEmbank11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>16103500</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\terreno_inundable_a\EcuadorFloodPlain11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>16240700</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\texto_descriptivo_l\EcuadorUniqueFeature11.shp.xml</srcused>
              <procdate>20130716</procdate>
              <proctime>16404000</proctime>
            </procstep>
            <procstep>
              <procdesc>Metadata imported.</procdesc>
              <srcused>S:\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\torre_agua_p\EcuadorWaterTower11.shp.xml</srcused>
              <procdate>20130717</procdate>
              <proctime>10330200</proctime>
            </procstep>
          </lineage>
        </dataqual>
        <spdoinfo>
          <direct>Vector</direct>
          <ptvctinf>
            <sdtsterm Name="Ecuador50KDrillingTower11">
              <sdtstype>Entity point</sdtstype>
              <ptvctcnt>1</ptvctcnt>
            </sdtsterm>
            <esriterm Name="Ecuador50KDrillingTower11">
      <efeatyp Sync="TRUE">Simple</efeatyp>
      <efeageom Sync="TRUE">Point</efeageom>
      <esritopo Sync="TRUE">FALSE</esritopo>
      <efeacnt Sync="TRUE">1</efeacnt>
      <spindex Sync="TRUE">TRUE</spindex>
      <linrefer Sync="TRUE">FALSE</linrefer>
      </esriterm>
      </ptvctinf>
        </spdoinfo>
        <spref>
          <horizsys>
            <planar>
              <planci>
                <plance>coordinate pair</plance>
                <coordrep>
                  <absres>0.000000</absres>
                  <ordres>0.000000</ordres>
                </coordrep>
                <plandu>meters</plandu>
              </planci>
              <gridsys>
      <gridsysn Sync="TRUE">Universal Transverse Mercator</gridsysn>
      <utm>
      <utmzone Sync="TRUE">-17</utmzone>
      <transmer>
      <sfctrmer Sync="TRUE">0.999600</sfctrmer>
      <longcm Sync="TRUE">-81.000000</longcm>
      <latprjo Sync="TRUE">0.000000</latprjo>
      <feast Sync="TRUE">500000.000000</feast>
      <fnorth Sync="TRUE">10000000.000000</fnorth>
      </transmer>
      </utm>
      </gridsys>
      </planar>
            <geodetic>
              <horizdn>D_WGS_1984</horizdn>
              <ellips>WGS_1984</ellips>
              <semiaxis>6378137.000000</semiaxis>
              <denflat>298.257224</denflat>
            </geodetic>
            <cordsysn>
      <geogcsn Sync="TRUE">GCS_WGS_1984</geogcsn>
      <projcsn Sync="TRUE">WGS_1984_UTM_Zone_17S</projcsn>
      </cordsysn>
      </horizsys>
        </spref>
        <eainfo>
          <detailed Name="Ecuador50KDrillingTower11">
            <enttyp>
              <enttypl>
      Ecuador50KDrillingTower11</enttypl>
              <enttypt Sync="TRUE">Feature Class</enttypt>
      <enttypc Sync="TRUE">1</enttypc>
      </enttyp>
            <attr>
              <attrlabl>FID</attrlabl>
              <attrdef>Internal feature number.</attrdef>
              <attrdefs>Environmental Systems Research Institute (Redlands, Calif.)</attrdefs>
              <attrdomv>
                <udom>Sequential unique whole numbers that are automatically generated.</udom>
              </attrdomv>
              <attalias Sync="TRUE">FID</attalias>
      <attrtype Sync="TRUE">OID</attrtype>
      <attwidth Sync="TRUE">4</attwidth>
      <atprecis Sync="TRUE">0</atprecis>
      <attscale Sync="TRUE">0</attscale>
      </attr>
            <attr>
              <attrlabl>Shape</attrlabl>
              <attrdef>Feature geometry.</attrdef>
              <attrdefs>Environmental Systems Research Institute (Redlands, Calif.)</attrdefs>
              <attrdomv>
                <udom>Coordinates defining the features.</udom>
              </attrdomv>
              <attalias Sync="TRUE">Shape</attalias>
      <attrtype Sync="TRUE">Geometry</attrtype>
      <attwidth Sync="TRUE">0</attwidth>
      <atprecis Sync="TRUE">0</atprecis>
      <attscale Sync="TRUE">0</attscale>
      </attr>
            <attr>
              <attrlabl>fcode</attrlabl>
              <attrdef>Feature class code</attrdef>
              <attrdefs>Tufts University. Geographic Information Systems Center</attrdefs>
              <attrdomv>
                <edom>
                  <edomv>AA040</edomv>
                  <edomvd>Vertical structure equipped for perforation purposes</edomvd>
                  <edomvds>Instituto Geografico Militar (Ecuador)</edomvds>
                </edom>
              </attrdomv>
              <attalias Sync="TRUE">fcode</attalias>
      <attrtype Sync="TRUE">String</attrtype>
      <attwidth Sync="TRUE">5</attwidth>
      </attr>
            <attr>
              <attrlabl>descripcio</attrlabl>
              <attrdef>Description of the FCODE</attrdef>
              <attrdefs>Tufts University. Geographic Information Systems Center</attrdefs>
              <attalias Sync="TRUE">descripcio</attalias>
      <attrtype Sync="TRUE">String</attrtype>
      <attwidth Sync="TRUE">250</attwidth>
      </attr>
            <attr>
              <attrlabl>ppo</attrlabl>
              <attrdef>Category of product</attrdef>
              <attrdefs>Instituto Geografico Militar (Ecuador)</attrdefs>
              <attrdomv>
                <edom>
                  <edomv>-1</edomv>
                  <edomvd>No information is available</edomvd>
                  <edomvds>Instituto Geografico Militar (Ecuador)</edomvds>
                </edom>
              </attrdomv>
              <attalias Sync="TRUE">ppo</attalias>
      <attrtype Sync="TRUE">Number</attrtype>
      <attwidth Sync="TRUE">4</attwidth>
      </attr>
            <attr>
              <attrlabl>ppo_desc</attrlabl>
              <attrdef>Description of the PPO code</attrdef>
              <attrdefs>Instituto Geografico Militar (Ecuador)</attrdefs>
              <attalias Sync="TRUE">ppo_desc</attalias>
      <attrtype Sync="TRUE">String</attrtype>
      <attwidth Sync="TRUE">80</attwidth>
      </attr>
            <attr>
              <attrlabl>txt</attrlabl>
              <attrdef>Further information about the tower</attrdef>
              <attrdefs>Instituto Geografico Militar (Ecuador)</attrdefs>
              <attalias Sync="TRUE">txt</attalias>
      <attrtype Sync="TRUE">String</attrtype>
      <attwidth Sync="TRUE">250</attwidth>
      </attr>
          </detailed>
        </eainfo>
        <distinfo>
          <distrib>
            <cntinfo>
              <cntorgp>
                <cntorg>Tufts University GIS Center</cntorg>
              </cntorgp>
              <cntpos>GIS Data Analyst</cntpos>
              <cntaddr>
                <addrtype>mailing and physical address</addrtype>
                <address>Academic Technology</address>
                <address>16 Dearborn Ave</address>
                <city>Somerville</city>
                <state>MA</state>
                <postal>02144</postal>
                <country>USA</country>
              </cntaddr>
              <cntvoice>617-627-3380</cntvoice>
              <cntemail>gis-support@elist.tufts.edu</cntemail>
              <hours>Monday-Friday, 9:00 AM-5:00 PM, EST-USA</hours>
            </cntinfo>
          </distrib>
          <resdesc>Online Dataset</resdesc>
          <stdorder>
            <digform>
              <digtinfo>
                <transize>13.102</transize>
                <dssize Sync="TRUE">0.000</dssize>
      </digtinfo>
            </digform>
          </stdorder>
        </distinfo>
        <metainfo>
          <metd>20130813</metd>
          <metc>
            <cntinfo>
              <cntorgp>
                <cntorg>Tufts University GIS Center</cntorg>
                <cntper>REQUIRED: The person responsible for the metadata information.</cntper>
              </cntorgp>
              <cntpos>GIS Data Analyst</cntpos>
              <cntaddr>
                <addrtype>mailing and physical address</addrtype>
                <address>Academic Technology</address>
                <address>16 Dearborn Ave</address>
                <city>Somerville</city>
                <state>MA</state>
                <postal>02144</postal>
                <country>USA</country>
              </cntaddr>
              <cntvoice>617-627-3380</cntvoice>
              <cntemail>gis-support@elist.tufts.edu</cntemail>
              <hours>Monday-Friday, 9:00 AM-5:00 PM, EST-USA</hours>
            </cntinfo>
          </metc>
          <metstdn>FGDC Content Standards for Digital Geospatial Metadata</metstdn>
          <metstdv>FGDC-STD-001-1998</metstdv>
          <mettc>local time</mettc>
          <metextns>
            <onlink>http://www.esri.com/metadata/esriprof80.html</onlink>
            <metprof>ESRI Metadata Profile</metprof>
          </metextns>
          <metextns>
            <onlink>http://www.esri.com/metadata/esriprof80.html</onlink>
            <metprof>ESRI Metadata Profile</metprof>
          </metextns>
          <metextns>
            <onlink>http://www.esri.com/metadata/esriprof80.html</onlink>
            <metprof>ESRI Metadata Profile</metprof>
          </metextns>
          <langmeta Sync="TRUE">en</langmeta>
      <metextns>
      <onlink Sync="TRUE">http://www.esri.com/metadata/esriprof80.html</onlink>
      <metprof Sync="TRUE">ESRI Metadata Profile</metprof>
      </metextns>
      </metainfo>
        <dataIdInfo>
      <envirDesc Sync="TRUE">Microsoft Windows Vista Version 6.1 (Build 7601) Service Pack 1; ESRI ArcCatalog 9.3.1.4000</envirDesc>
      <dataLang>
      <languageCode Sync="TRUE" value="en" />
      </dataLang>
      <idCitation>
      <resTitle Sync="TRUE">Ecuador50KDrillingTower11</resTitle>
      <presForm>
      <PresFormCd Sync="TRUE" value="005" />
      </presForm>
      </idCitation>
      <spatRpType>
      <SpatRepTypCd Sync="TRUE" value="001" />
      </spatRpType>
      <dataExt>
      <geoEle>
      <GeoBndBox esriExtentType="native">
      <westBL Sync="TRUE">621844.3882</westBL>
      <eastBL Sync="TRUE">621844.3882</eastBL>
      <northBL Sync="TRUE">9847689.6686</northBL>
      <southBL Sync="TRUE">9847689.6686</southBL>
      <exTypeCode Sync="TRUE">1</exTypeCode>
      </GeoBndBox>
      </geoEle>
      </dataExt>
      <geoBox esriExtentType="decdegrees">
      <westBL Sync="TRUE">-79.904768</westBL>
      <eastBL Sync="TRUE">-79.904768</eastBL>
      <northBL Sync="TRUE">-1.377743</northBL>
      <southBL Sync="TRUE">-1.377743</southBL>
      <exTypeCode Sync="TRUE">1</exTypeCode>
      </geoBox>
      </dataIdInfo>
      <mdLang>
      <languageCode Sync="TRUE" value="en" />
      </mdLang>
      <mdStanName Sync="TRUE">ISO 19115 Geographic Information - Metadata</mdStanName>
      <mdStanVer Sync="TRUE">DIS_ESRI1.0</mdStanVer>
      <mdChar>
      <CharSetCd Sync="TRUE" value="004" />
      </mdChar>
      <mdHrLv>
      <ScopeCd Sync="TRUE" value="005" />
      </mdHrLv>
      <mdHrLvName Sync="TRUE">dataset</mdHrLvName>
      <distInfo>
      <distributor>
      <distorTran>
      <onLineSrc>
      <orDesc Sync="TRUE">002</orDesc>
      <linkage Sync="TRUE">file://\\rstore2\gisprojects$\GIS_Center_Projects\EnterpriseGIS\Layers\Ecuador\IGM - Instituto Geografico Militar\Base Level Infrastructure\torre_perforacion_p\Ecuador50KDrillingTower11.shp</linkage>
      <protocol Sync="TRUE">Local Area Network</protocol>
      </onLineSrc>
      <transSize Sync="TRUE">0.000</transSize>
      </distorTran>
      <distorFormat>
      <formatName Sync="TRUE">Shapefile</formatName>
      </distorFormat>
      </distributor>
      </distInfo>
      <refSysInfo>
      <RefSystem>
      <refSysID>
      <identCode Sync="TRUE">WGS_1984_UTM_Zone_17S</identCode>
      </refSysID>
      </RefSystem>
      </refSysInfo>
      <spatRepInfo>
      <VectSpatRep>
      <topLvl>
      <TopoLevCd Sync="TRUE" value="001" />
      </topLvl>
      <geometObjs Name="Ecuador50KDrillingTower11">
      <geoObjTyp>
      <GeoObjTypCd Sync="TRUE" value="004" />
      </geoObjTyp>
      <geoObjCnt Sync="TRUE">1</geoObjCnt>
      </geometObjs>
      </VectSpatRep>
      </spatRepInfo>
      <Esri>
      <SyncDate>20140520</SyncDate>
      <SyncTime>16090500</SyncTime>
      <ModDate>20140520</ModDate>
      <ModTime>16090500</ModTime>
      </Esri>
      <mdDateSt Sync="TRUE">20140520</mdDateSt>
      </metadata>
    xml
  end
end
