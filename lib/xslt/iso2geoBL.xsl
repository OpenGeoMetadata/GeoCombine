<?xml version="1.0" encoding="UTF-8"?>
<!-- 
     iso2geoBl.xsl - Transformation from ISO 19139 XML into GeoBlacklight solr
     
     Created by Kim Durante and Darren Hardy, Stanford University Libraries
     
     NOTES:
     
    * An institution variable needs to be mapped for each proivder.
     *Values for UUIDs and Identifiers need to be mapped for each institution. Best practice is to use a universally unique identifier, which can be expressed as a URI.
     *Conditions for the Rights statements ('Public' vs. 'Restricted') need work, default is to restricted if undetermined.
     *Currently, the only mapping for languages is English
     
     *Metadata elements are auto-generated for these fields:
    
     -geometry type
     -references
          
-->

<xsl:stylesheet 
  xmlns="http://www.loc.gov/mods/v3" 
  xmlns:gco="http://www.isotc211.org/2005/gco" 
  xmlns:gmi="http://www.isotc211.org/2005/gmi" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gml="http://www.opengis.net/gml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="2.0" exclude-result-prefixes="gml gmd gco gmi xsl">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>

    <!-- institution  -->
  <xsl:variable name="institution">
    <xsl:for-each select="gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty">
      <xsl:choose>
        
       <!-- Stanford --> 
       <xsl:when test="contains(gmd:organisationName/gco:CharacterString, 'Stanford')">
          <xsl:text>Stanford</xsl:text>
        </xsl:when>
       
        <!-- UVa --> 
        <xsl:when test="contains(gmd:organisationName/gco:CharacterString, 'Virginia')">
          <xsl:text>UVa</xsl:text>
        </xsl:when>
        <xsl:when test="contains(gmd:organisationName/gco:CharacterString, 'Scholars&apos;)">
          <xsl:text>UVa</xsl:text>
        </xsl:when>
        
        </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  
<!-- bounding box -->
<xsl:variable name="upperCorner">
  <xsl:value-of select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)"/>
  <xsl:text> </xsl:text>
  <xsl:value-of select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)"/>
</xsl:variable>
  
  <xsl:variable name="lowerCorner">

    <xsl:value-of select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)"/>
      <xsl:text> </xsl:text>
    <xsl:value-of select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)"/>

  </xsl:variable>
  <xsl:variable name="x2" select="substring-before($upperCorner/text(), ' ')"/><!-- E -->
  <xsl:variable name="x1" select="substring-before($lowerCorner/text(), ' ')"/><!-- W -->
  <xsl:variable name="y2" select="substring-after($upperCorner/text(), ' ')"/><!-- N -->
  <xsl:variable name="y1" select="substring-after($lowerCorner/text(), ' ')"/><!-- S -->


  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="contains(gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name, 'GeoTIFF')">
        <xsl:text>GeoTIFF</xsl:text>
      </xsl:when>
    <xsl:when test="contains(gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name, 'Raster Dataset')">
      <xsl:text>ArcGRID</xsl:text>
    </xsl:when>
      <xsl:when test="contains(gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name, 'Shapefile')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue='vector'">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue='grid'">
        <xsl:text>ArcGRID</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- TODO: need to handle other institution uuids -->
  <xsl:variable name="uuid">
    <xsl:choose>
      <xsl:when test="contains($institution, 'Stanford')">
        <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:name"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:variable>
  
  
  <xsl:variable name="identifier">
    <xsl:choose>
      
   <!-- for Stanford URIs -->

      <xsl:when test="contains($uuid, 'purl')">
        <xsl:value-of select="substring($uuid, string-length($uuid)-10)"/>
      </xsl:when>
      
   <!-- all others -->
      
      <xsl:otherwise>
        <xsl:value-of select="$uuid"/>
      </xsl:otherwise>
       </xsl:choose>
  </xsl:variable>

<xsl:template match="/">
    <add>
      <doc>
        <field name="uuid">
        <xsl:value-of select="$uuid"/>
        </field>
       
        <field name="dc_identifier_s">
        <xsl:value-of select="$uuid"/>
        </field>
        
        <field name="dc_title_s">
          <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
        </field>
        <field name="dc_description_s">
          <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract"/>
        </field>
        
        <field name="dc_rights_s">
          <xsl:choose>
          <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints/gmd:MD_RestrictionCode[@codeListValue='restricted']">
            <xsl:text>Restricted</xsl:text>
          </xsl:when>
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints/gmd:MD_RestrictionCode, 'restricted')">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints/gmd:MD_RestrictionCode[@codeListValue='restricted']">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints/gmd:MD_RestrictionCode, 'restricted')">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints">
          <xsl:choose>
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints, 'restricted')">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints, 'public domain')">
              <xsl:text>Public</xsl:text>
            </xsl:when>
            
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints, $institution)">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Restricted</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
         </xsl:when>
       </xsl:choose>
     </field>
     
     <field name="dct_provenance_s">
       <xsl:value-of select="$institution"/>
     </field>

        <!-- <field name="dct_references_s">
          <xsl:text>{</xsl:text>
          <xsl:text>"http://schema.org/url":"</xsl:text>              
          <xsl:value-of select="$uuid"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"http://schema.org/thumbnailUrl":"</xsl:text>              
          <xsl:value-of select="$stacks_root"/>
          <xsl:text>/file/druid:</xsl:text>
          <xsl:value-of select="$identifier"/>
          <xsl:text>/preview.jpg",</xsl:text>
          <xsl:text>"http://schema.org/DownloadAction":"</xsl:text>              
          <xsl:value-of select="$stacks_root"/>
          <xsl:text>/file/druid:</xsl:text>
          <xsl:value-of select="$identifier"/>
          <xsl:text>/data.zip",</xsl:text>
          <xsl:text>"http://www.loc.gov/mods/v3":"</xsl:text>              
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/edu.stanford.purl/</xsl:text>
          <xsl:value-of select="$identifier"/>
          <xsl:text>/mods",</xsl:text>
          <xsl:text>"http://www.isotc211.org/schemas/2005/gmd/":"</xsl:text>              
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/edu.stanford.purl/</xsl:text>
          <xsl:value-of select="$identifier"/>
          <xsl:text>/iso19139",</xsl:text>
          <xsl:text>"http://www.opengis.net/def/serviceType/ogc/wms":"</xsl:text>
          <xsl:value-of select="$geoserver_root"/>
          <xsl:text>/wms",</xsl:text>
          <xsl:text>"http://www.opengis.net/def/serviceType/ogc/wfs":"</xsl:text>
          <xsl:value-of select="$geoserver_root"/>
          <xsl:text>/wfs",</xsl:text>
          <xsl:text>"http://www.opengis.net/def/serviceType/ogc/wcs":"</xsl:text>
          <xsl:value-of select="$geoserver_root"/>
          <xsl:text>/wcs"</xsl:text>
          <xsl:text>}</xsl:text> 
        </field> -->
          
        <field name="layer_id_s">
          <xsl:choose>
            <xsl:when test="$institution = 'Stanford'">
              <xsl:text>druid:</xsl:text>
              <xsl:value-of select="$identifier"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>urn:</xsl:text>
              <xsl:value-of select="$identifier"/>
            </xsl:otherwise>
          </xsl:choose>
        </field>
        
        <field name="layer_slug_s">
          <xsl:value-of select="$institution"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="$identifier"/>

        </field>
        
        <!-- auto-generated 
        <field name="layer_geom_type_s">
          <xsl:value-of select="$geometryType"/>
        </field>
        -->

          <xsl:choose>
            <xsl:when test="contains(gmd:MD_Metadata/gmd:dateStamp, 'T')">
              <field name="layer_modified_dt">
             <xsl:value-of select="gmd:MD_Metadata/gmd:dateStamp"/>
              </field>
            </xsl:when>
            <xsl:otherwise>
              <field name="layer_modified_dt">
              <xsl:value-of select="gmd:MD_Metadata/gmd:dateStamp"/>
                <xsl:text>T00:00:00Z</xsl:text>
              </field>
            </xsl:otherwise>
          </xsl:choose>
        
        
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty">
      

            <xsl:if test="gmd:role/gmd:CI_RoleCode[@codeListValue='originator']">
              <xsl:for-each select="gmd:organisationName">
                <field name="dc_creator_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
              <xsl:for-each select="gmd:personalName">
                <field name="dc_creator_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
            </xsl:if>
            
            <xsl:if test="gmd:role/gmd:CI_RoleCode[@codeListValue='publisher']">
              
              <xsl:for-each select="gmd:organisationName">
                <field name="dc_publisher_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
              <xsl:for-each select="gmd:individualName">
                <field name="dc_creator_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
        
         <field name="dc_format_s">
          <xsl:value-of select="$format"/>
        </field> 
        
        <!-- TODO: add inputs for other languages -->
        <field name="dc_language_s">
          <xsl:if test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language | gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language/gmd:LanguageCode[0], 'eng')">
            <xsl:text>English</xsl:text>
          </xsl:if>
       </field>
        
        <!-- from DCMI type vocabulary -->
       <xsl:choose>
         <xsl:when test="contains(gmd:MD_Metadata/gmd:hierarchyLevelName/gco:CharacterString, 'dataset')">
            <field name="dc_type_s">
             <xsl:text>Dataset</xsl:text>
           </field>
         </xsl:when>
          
          
          <xsl:when test="contains(gmd:MD_Metadata/gmd:hierarchyLevelName/gco:CharacterString, 'service')">
            <field name="dc_type_s">
              <xsl:text>Service</xsl:text>
            </field>
          </xsl:when>
       </xsl:choose>

        <!-- translate ISO topic categories -->
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
            <field name="dc_subject_sm">
              <xsl:choose>
                <xsl:when test="contains(.,'farming')">

                  <xsl:text>Farming</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'biota')">

                  <xsl:text>Biology and Ecology</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'climatologyMeteorologyAtmosphere')">

                  <xsl:text>Climatology, Meteorology and Atmosphere</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'boundaries')">

                  <xsl:text>Boundaries</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'elevation')">

                  <xsl:text>Elevation</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'environment')">

                  <xsl:text>Environment</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'geoscientificInformation')">

                  <xsl:text>Geoscientific Information</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'health')">

                  <xsl:text>Health</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'imageryBaseMapsEarthCover')">

                  <xsl:text>Imagery and Base Maps</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'intelligenceMilitary')">

                  <xsl:text>Military</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'inlandWaters')">

                  <xsl:text>Inland Waters</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'location')">

                  <xsl:text>Location</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'oceans')">

                  <xsl:text>Oceans</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'planningCadastre')">

                  <xsl:text>Planning and Cadastral</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'structure')">

                  <xsl:text>Structure</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'transportation')">

                  <xsl:text>Transportation</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'utilitiesCommunication')">

                  <xsl:text>Utilities and Communication</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'society')">

                  <xsl:text>Society</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'economy')">
                  
                  <xsl:text>Economy</xsl:text>
                </xsl:when>
                
                <xsl:otherwise>
                  <xsl:value-of select="."/>
                </xsl:otherwise>
              </xsl:choose>
            </field>
          </xsl:for-each>
        
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords">
          <xsl:choose>
            <xsl:when test="gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='theme']">
              <xsl:for-each select="gmd:keyword">
              <field name="dc_subject_sm">
              <xsl:value-of select="."/>
              </field>
              </xsl:for-each>
            </xsl:when>
            
            <xsl:when test="gmd:type/gmd:MD_KeywordTypeCode[@codeListValue='place']">
              <xsl:for-each select="gmd:keyword">
                <field name="dc_spatial_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
            </xsl:when>
           </xsl:choose>
        </xsl:for-each>
        

          <xsl:choose>
            <xsl:when test="contains(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime, 'T')">
              <field name="dct_issued_s">
              <xsl:value-of select="substring-before(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime,'T')"/>
              </field>
            </xsl:when>
            
            <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime">
              <field name="dct_issued_s">
              <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:DateTime"/>
              </field>
            </xsl:when>

            <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date">
              <field name="dct_issued_s">
              <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/gco:Date"/>
              </field>
            </xsl:when>
            
            <xsl:otherwise>unknown</xsl:otherwise>
          </xsl:choose>
        
        
      <!-- content date: range YYYY-YYYY if dates differ  -->

              <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition">
              <field name="dct_temporal_sm">
              <xsl:value-of select="substring(., 1,4)"/>
                <xsl:if test="substring(ancestor-or-self::*/gml:endPosition, 1,4) != substring(ancestor-or-self::*/gml:beginPosition,1,4)">  
              <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(ancestor-or-self::*/gml:endPosition, 1,4)"/>
              </xsl:if>
              </field>
              </xsl:for-each>
  
            

              <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant">
              <field name="dct_temporal_sm">
                <xsl:value-of select="substring(gml:timePosition, 1,4)"/>
              </field> 
              </xsl:for-each>
        
        <!-- collection -->
        
        <xsl:choose>
          <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='largerWorkCitation']">
            <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='largerWorkCitation']">
            <field name="dct_isPartOf_sm">
              <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title"/>
           </field>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:collectiveTitle">
            <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:collectiveTitle">
            <field name="dct_isPartOf_sm">
              <xsl:value-of select="."/>
            </field>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
     
        <!-- cross-references -->
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='crossReference']">
           <field name="dc_relation_sm">
             <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title"/>
           </field>
         </xsl:for-each>
        
          <field name="georss_polygon_s">
          <xsl:text></xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x1"/>
        </field>
        
        <field name="solr_geom">
          <xsl:text>ENVELOPE(</xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text>)</xsl:text>
        </field>
        
        <field name="georss_box_s">
          <xsl:value-of select="$y1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x2"/>
        </field>
              
        <!-- content date: singular, or beginning date of range: YYYY -->
         <xsl:choose>
           <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition/text() != ''">
              <field name="solr_year_i">
              <xsl:value-of select="substring(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 1,4)"/>
              </field>         
            </xsl:when>
            <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant">
              <field name="solr_year_i">
                <xsl:value-of select="substring(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant, 1,4)"/>
              </field> 
            </xsl:when>
       </xsl:choose>
      </doc>
    </add>
  </xsl:template>

</xsl:stylesheet>
