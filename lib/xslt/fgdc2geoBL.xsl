<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  
fgdc2geoBL.xsl - Transformation from FGDC into GeoBlacklight Solr

Created by Kim Durante and Darren Hardy, Stanford University Libraries
     
     NOTES:
     
    * An institution variable needs to be mapped for each data proivder.
     *Values for UUIDs and Identifiers need to be mapped for each institution. Best practice is to use a universally unique identifier, which can be expressed as a URI. 
         Many FGDC records do not contain identifiers. A uuid schema needs to be identified.
     *Conditions for the Rights statements ('Public' vs. 'Restricted') need work, default is to restricted if undetermined.
     *Currently, the only mapping for languages is English
     *References needs work
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

    <xsl:variable name="institution">
        <xsl:for-each select="metadata">
            <xsl:choose>
                <xsl:when test="contains(distinfo/distrib/cntinfo/cntorgp/cntorg, 'Harvard')">
                    <xsl:text>Harvard</xsl:text>
                </xsl:when> 
                <xsl:when test="contains(distinfo/distrib/cntinfo/cntorgp/cntorg, 'Tufts')">
                    <xsl:text>Tufts</xsl:text>
                </xsl:when> 
                <xsl:when test="contains(distinfo/distrib/cntinfo/cntorgp/cntorg, 'MIT')">
                    <xsl:text>MIT</xsl:text>
                </xsl:when>
                <xsl:when test="contains(cntinfo/cntorgp/cntorg, 'Massachusetts')">
                    <xsl:text>MassGIS</xsl:text>
                </xsl:when>
                <xsl:when test="contains(metainfo/metc/cntinfo/cntorgp/cntorg, 'MassGIS')">
                    <xsl:text>MassGIS</xsl:text>
                </xsl:when>
                <xsl:when test="contains(distinfo/distrib/cntinfo/cntemail, 'state.ma.us')">
                    <xsl:text>MassGIS</xsl:text>
                </xsl:when>
                <xsl:when test="contains(metainfo/metc/cntinfo/cntemail, 'ca.gov')">
                    <xsl:text>Berkeley</xsl:text>
                </xsl:when>
                <xsl:when test="contains(metainfo/metc/cntinfo/cntorgp/cntorg, 'Columbia')">
                    <xsl:text>Columbia</xsl:text>
                </xsl:when>
              <xsl:when test="contains(metainfo/metc/cntinfo/cntorgp/cntorg, 'Princeton')">
                <xsl:text>Princeton</xsl:text>
              </xsl:when>
                <xsl:when test="contains(metainfo/metc/cntinfo/cntorgp/cntorg, 'Harvard')">
                    <xsl:text>Harvard</xsl:text>
                </xsl:when>
                
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
  
<!-- Output bounding box -->
<xsl:variable name="upperCorner">
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/eastbc)"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="number(metadata/idinfo/spdom/bounding/northbc)"/>
</xsl:variable>
  
 <xsl:variable name="lowerCorner">
     <xsl:value-of select="number(metadata/idinfo/spdom/bounding/westbc)"/>
     <xsl:text> </xsl:text>
     <xsl:value-of select="number(metadata/idinfo/spdom/bounding/southbc)"/>
</xsl:variable>
  
  <xsl:variable name="x2" select="substring-before($upperCorner/text(), ' ')"/><!-- E -->
  <xsl:variable name="x1" select="substring-before($lowerCorner/text(), ' ')"/><!-- W -->
  <xsl:variable name="y2" select="substring-after($upperCorner/text(), ' ')"/><!-- N -->
  <xsl:variable name="y1" select="substring-after($lowerCorner/text(), ' ')"/><!-- S -->

  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'raster digital data')">
      <xsl:text>ArcGRID</xsl:text>
    </xsl:when>
    <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'remote-sensing image')">
       <xsl:text>ArcGRID</xsl:text>
    </xsl:when>
        <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'TIFF')">
            <xsl:text>GeoTIFF</xsl:text>
        </xsl:when>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'vector digital data')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'Shape')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  
  <xsl:variable name="uuid">
    <xsl:choose>
      <xsl:when test="$institution = 'Harvard'">
        <xsl:choose>
          <xsl:when test="contains(metadata/idinfo/citation/citeinfo/onlink, 'CollName=')">       
            <xsl:value-of select="substring-after(metadata/idinfo/citation/citeinfo/onlink, 'CollName=')"/>
          </xsl:when>
          <xsl:when test="metadata/spdoinfo/ptvctinf/sdtsterm">
            <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
          </xsl:when>
          <xsl:when test="metadata/idinfo/citation/citeinfo/ftname">
            <xsl:value-of select="metadata/idinfo/citation/citeinfo/ftname"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="$institution = 'MIT'">
        <xsl:choose>
          <xsl:when test="metadata/spdoinfo/ptvctinf/sdtsterm">
            <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
          </xsl:when>
          <xsl:when test="metadata/idinfo/citation/citeinfo/ftname">
            <xsl:value-of select="metadata/idinfo/citation/citeinfo/ftname"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
        
      <xsl:when test="$institution = 'Tufts'">
        <xsl:choose>
          <xsl:when test="metadata/idinfo/citation/citeinfo/ftname">
            <xsl:value-of select="metadata/idinfo/citation/citeinfo/ftname"/>
          </xsl:when>
        <xsl:when test="metadata/spdoinfo/ptvctinf/sdtsterm">
        <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
        </xsl:when>
       </xsl:choose>
      </xsl:when>
        
      <xsl:when test="$institution = 'Princeton'">
        <xsl:choose>
          <xsl:when test="contains(metadata/idinfo/citation/citeinfo/onlink, 'data/')">
             <xsl:value-of select="translate(substring-before(substring-after(metadata/idinfo/citation/citeinfo/onlink, 'data/'), '/content'), '/', '')"/>
         </xsl:when>
          <xsl:when test="metadata/spdoinfo/ptvctinf/sdtsterm">
            <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
          </xsl:when>
    </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  
  <xsl:template match="metadata">
    <add>
      <doc>
        <field name="uuid">
         <xsl:value-of select="$uuid"/>
        </field>
        <field name="dc_identifier_s">
            <xsl:value-of select="idinfo/citation/citeinfo/onlink"/>
        </field>
        
        <field name="dc_title_s">
            <xsl:value-of select="idinfo/citation/citeinfo/title"/>
        </field>
        <field name="dc_description_s">
            <xsl:value-of select="idinfo/descript/abstract"/>
        </field>
        
        
        <field name="dc_rights_s">
          <xsl:choose>
            <xsl:when test="contains(idinfo/accconst, 'Restricted')">
            <xsl:text>Restricted</xsl:text>
          </xsl:when>
            <xsl:when test="contains(idinfo/accconst, 'Unrestricted')">
              <xsl:text>Public</xsl:text>
            </xsl:when>
            <xsl:when test="contains(idinfo/accconst, 'No restriction')">
              <xsl:text>Public</xsl:text>
            </xsl:when>
            <xsl:when test="contains(idinfo/accconst, $institution)">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
          <xsl:when test="contains(idinfo/accconst, 'None')">
            <xsl:text>Public</xsl:text>
           </xsl:when>
            <xsl:when test="contains(idinfo/useconst, 'Restricted')">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:when test="contains(idinfo/useconst, $institution)">
              <xsl:text>Restricted</xsl:text>
            </xsl:when>
            <xsl:when test="contains(idinfo/useconst, 'None')">
              <xsl:text>Public</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Restricted</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
           </field>
     
     <field name="dct_provenance_s">
       <xsl:value-of select="$institution"/>
     </field>
        
 <!--     <field name="dct_references_s">
          <xsl:text>{</xsl:text>
          <xsl:text>"http://schema.org/url":"</xsl:text>              
          <xsl:value-of select="$purl"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"http://schema.org/thumbnailUrl":"</xsl:text>              
          <xsl:value-of select="$stacks_root"/>
          <xsl:text>/file/druid:</xsl:text>
          <xsl:value-of select="$druid"/>
          <xsl:text>/preview.jpg",</xsl:text>
          <xsl:text>"http://schema.org/DownloadAction":"</xsl:text>              
          <xsl:value-of select="$stacks_root"/>
          <xsl:text>/file/druid:</xsl:text>
          <xsl:value-of select="$druid"/>
          <xsl:text>/data.zip",</xsl:text>
          <xsl:text>"http://www.loc.gov/mods/v3":"</xsl:text>              
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/</xsl:text>
          <xsl:value-of select="$druid"/>
          <xsl:text>/mods",</xsl:text>
          <xsl:text>"http://www.isotc211.org/schemas/2005/gmd/":"</xsl:text>              
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/</xsl:text>
          <xsl:value-of select="$druid"/>
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
        </field>  -->
       
        <field name="layer_id_s">
          <xsl:text>urn:</xsl:text>
          <xsl:value-of select="$uuid"/>
        </field> 
        
        <field name="layer_slug_s">
            <xsl:value-of select="lower-case($institution)"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$uuid"/>
        </field>
        
    <!-- geometry type can be auto-generated -->
        
            <xsl:choose>
                <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'G-polygon')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Polygon</xsl:text>
                  </field>
                </xsl:when>
                <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'Entity point')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Point</xsl:text>
                  </field>   
                </xsl:when>
                
                <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'String')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Line</xsl:text>
                  </field>   
                </xsl:when>
                <xsl:when test="contains(metadata/spdoinfo/direct, 'Raster')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Raster</xsl:text>
                  </field>   
                </xsl:when>
             </xsl:choose>
       
            <xsl:choose>
              <xsl:when test="string-length(metainfo/metd)=4">
                <field name="layer_modified_dt">
                <xsl:value-of select="metainfo/metd"/>  
                </field>   
              </xsl:when>
               
               <xsl:when test="string-length(metainfo/metd)=6">
                 <field name="layer_modified_dt">
                 <xsl:value-of select="substring(metainfo/metd,1,4)"/>  
                 <xsl:text>-</xsl:text>
                 <xsl:value-of select="substring(metainfo/metd,5,2)"/>
                 </field>  
               </xsl:when>
               
               <xsl:when test="string-length(metainfo/metd)=8">
                 <field name="layer_modified_dt">
                 <xsl:value-of select="substring(metainfo/metd,1,4)"/>  
                 <xsl:text>-</xsl:text>
                 <xsl:value-of select="substring(metainfo/metd,5,2)"/>  
                 <xsl:text>-</xsl:text>
                 <xsl:value-of select="substring(metainfo/metd,7,2)"/>
                 </field>  
               </xsl:when>
             </xsl:choose>
        
        
          <xsl:for-each select="idinfo/citation/citeinfo/origin">
                <field name="dc_creator_sm">
                  <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
 
          <xsl:for-each select="idinfo/citation/citeinfo/pubinfo/publish">
                <field name="dc_publisher_sm">
                  <xsl:value-of select="."/>
                </field>
          </xsl:for-each>
             
  
        <field name="dc_format_s">
            <xsl:value-of select="$format"/>
        </field>
        
        
    <!-- TODO: map other languages -->
        <xsl:if test="contains(idinfo/descript/langdata, 'en')">
        <field name="dc_language_s">
          <xsl:text>English</xsl:text>
       </field>
       </xsl:if>
        
        <!-- DCMI Type vocabulary: defaults to dataset -->
        <field name="dc_type_s">
          <xsl:text>Dataset</xsl:text>
        </field>


        <!-- translate ISO topic categories -->
          <xsl:for-each select="idinfo/keywords/theme">
              <xsl:choose>
               <xsl:when test="contains(themekt, '19115')">
                <xsl:for-each select="themekey">

                <field name="dc_subject_sm">
                <xsl:choose>
                <xsl:when test="contains(.,'farming')">

                  <xsl:text>Farming</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'biota')">

                  <xsl:text>Biology and Ecology</xsl:text>
                </xsl:when>
                <xsl:when test="contains(.,'climatologyMeteorologyAtmosphere')">\

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
           </xsl:when>
                
           <xsl:when test="not(themekt = 'FGDC')">
             <xsl:for-each select="themekey">
                  <field name="dc_subject_sm">
                      <xsl:value-of select="."/>
                  </field>
              </xsl:for-each>
                  </xsl:when>
              </xsl:choose>
          </xsl:for-each>
            
          
          <xsl:for-each select="idinfo/keywords/place/placekey">
                <field name="dc_spatial_sm">
                  <xsl:value-of select="."/>
                </field>
          </xsl:for-each>
          
          <xsl:choose>
            <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=4">
              <field name="dct_issued_s">
              <xsl:value-of select="idinfo/citation/citeinfo/pubdate"/>  
              </field>  
            </xsl:when>
            
            <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=6">
              <field name="dct_issued_s">
              <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>  
              <xsl:text>-</xsl:text>
              <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>  
              </field>  
            </xsl:when>
            
            <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=8">
              <field name="dct_issued_s">
              <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>  
              <xsl:text>-</xsl:text>
              <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>  
              <xsl:text>-</xsl:text>
              <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,7,2)"/> 
              </field>  
            </xsl:when>
          </xsl:choose>

          <!-- singular content date: YYYY -->

            <xsl:for-each select="idinfo/timeperd/timeinfo/sngdate/caldate">
              <xsl:if test="text() !='' ">
            <field name="dct_temporal_sm">
               <xsl:value-of select="substring(.,1,4)"/>
            </field>
              </xsl:if>
            </xsl:for-each>
            

            <xsl:for-each select="idinfo/timeperd/timeinfo/mdattim/sngdate">  
            <field name="dct_temporal_sm">  
             <xsl:value-of select="substring(caldate,1,4)"/>
            </field>  
            </xsl:for-each>  
           
            
            <!-- months, days YYYY-MM, YYYY-MM-DD
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=4">
             <xsl:value-of select="idinfo/timeperd/timeinfo/sngdate/caldate"/>
             </xsl:when>
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=6">
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,5,2)"/>
             </xsl:when>
             <xsl:when test="string-length(idinfo/timeperd/timeinfo/sngdate/caldate)=8">
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,5,2)"/>
             <xsl:text>-</xsl:text>
             <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,7,2)"/>
             </xsl:when>  -->
            
           <!-- content date range: YYYY-YYYY if dates in range differ -->
    
              <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
              <field name="dct_temporal_sm">
              <xsl:value-of select="substring(begdate, 1,4)"/>
              <xsl:if test="substring(begdate,1,4) != substring(enddate,1,4)"> 
              <xsl:text>-</xsl:text>
              <xsl:value-of select="substring(enddate,1,4)"/>
              </xsl:if>
              </field>  
              </xsl:for-each>
        
          <xsl:for-each select="idinfo/keywords/temporal/tempkey">
           <xsl:if test="text() != substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)">
            <field name="dct_temporal_sm">
            <xsl:value-of select="."/>
            </field>
          </xsl:if>
         </xsl:for-each>
        
             

               
             
    
        <!-- collection -->
        

        <xsl:for-each select="idinfo/citation/citeinfo/lworkcit/citeinfo">
        <field name="dct_isPartOf_sm">
          <xsl:value-of select="title"/>
        </field>
        </xsl:for-each>
     
 
        <xsl:for-each select="idinfo/citation/citeinfo/serinfo/sername">
        <field name="dct_isPartOf_sm">
           <xsl:value-of select="."/>
        </field>
         </xsl:for-each>
          
        <!-- cross-references -->
        
        <xsl:for-each select="idinfo/crossref/citeinfo">
          <field name="dc_relation_sm">
            <xsl:value-of select="title"/>
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
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
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
      
        <!-- content date for solr year: choose singular, or beginning date of range: YYYY -->
        <xsl:for-each select="idinfo/timeperd/timeinfo">
            <xsl:choose>
                <xsl:when test="sngdate/text != ''">
                  <xsl:if test="position() = 1">
                  <field name="solr_year_i">
                    <xsl:value-of select="substring(sngdate/caldate,1,4)"/>
                  </field>   
                  </xsl:if>
               </xsl:when>
             
              <xsl:when test="mdattim/sngdate/caldate">
                <xsl:if test="position() = 1">
                 <field name="solr_year_i">
                  <xsl:value-of select="substring(caldate,1,4)"/>
                </field>  
                </xsl:if>
              </xsl:when>
              
              <xsl:when test="rngdates/begdate/text() != ''[1]">
                <xsl:if test="position() = 1">
                <field name="solr_year_i">
                  <xsl:value-of select="substring(rngdates/begdate/text(), 1,4)"/>
                </field>
                </xsl:if>
             </xsl:when>
              
              <xsl:when test="//metadata/idinfo/keywords/temporal/tempkey">
                <xsl:for-each select="//metadata/idinfo/keywords/temporal/tempkey[1]">
                  <xsl:if test="text() != ''">
                    <field name="solr_year_i">
                      <xsl:value-of select="."/>
                    </field>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
           </xsl:choose>
        </xsl:for-each>
        </doc>
    </add>
  </xsl:template>
       
</xsl:stylesheet>