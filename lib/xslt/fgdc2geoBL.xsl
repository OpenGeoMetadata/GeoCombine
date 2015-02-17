<?xml version="1.0" encoding="UTF-8"?>
<!-- 
     fgdc2geoBL.xsl - Transformation from FGDC into GeoBlacklight Solr
     
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

  <xsl:param name="zipName" select="'data.zip'"/>

    
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
  <xsl:variable name="x2" select="number(metadata/idinfo/spdom/bounding/eastbc)"/><!-- E -->
  <xsl:variable name="x1" select="number(metadata/idinfo/spdom/bounding/westbc)"/><!-- W -->
  <xsl:variable name="y2" select="number(metadata/idinfo/spdom/bounding/northbc)"/><!-- N -->
  <xsl:variable name="y1" select="number(metadata/idinfo/spdom/bounding/southbc)"/><!-- S -->

  
  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'raster digital data')">
      <xsl:text>image/tiff</xsl:text>
    </xsl:when>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'vector digital data')">
        <xsl:text>application/x-esri-shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'TIFF')">
        <xsl:text>image/tiff</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'JPEG2000')">
        <xsl:text>image/tiff</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'Shape')">
        <xsl:text>application/x-esri-shapefile</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  
  <xsl:variable name="uuid">
    <xsl:choose>
      <xsl:when test="$institution = 'Harvard'">
        <xsl:value-of select="substring-after(metadata/idinfo/citation/citeinfo/onlink, 'CollName=')"/>
      </xsl:when>
      <xsl:when test="$institution = 'MIT'">
        <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
      </xsl:when>
      <xsl:when test="$institution = 'Tufts'">
        <xsl:value-of select="metadata/spdoinfo/ptvctinf/sdtsterm/@Name"/>
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
          </xsl:choose>
           </field>
     
     <field name="dct_provenance_s">
       <xsl:value-of select="$institution"/>
     </field>
        
 <!--       <field name="dct_references_s">
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
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/edu.stanford.purl/</xsl:text>
          <xsl:value-of select="$druid"/>
          <xsl:text>/mods",</xsl:text>
          <xsl:text>"http://www.isotc211.org/schemas/2005/gmd/":"</xsl:text>              
          <xsl:text>http://earthworks.stanford.edu/opengeometadata/layers/edu.stanford.purl/</xsl:text>
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
        
      
            <xsl:choose>
                <xsl:when test="contains(spdoinfo/ptvctinf/sdtsterm/sdtstype, 'G-polygon')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Polygon</xsl:text>
                  </field>
                </xsl:when>
                <xsl:when test="contains(spdoinfo/ptvctinf/sdtsterm/sdtstype, 'Entity point')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Point</xsl:text>
                  </field>   
                </xsl:when>
                
                <xsl:when test="contains(spdoinfo/ptvctinf/sdtsterm/sdtstype, 'String')">
                  <field name="layer_geom_type_s">
                    <xsl:text>Line</xsl:text>
                  </field>   
                </xsl:when>
                <xsl:when test="contains(spdoinfo/direct, 'Raster')">
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

          <xsl:choose>
            <xsl:when test="idinfo/timeperd/timeinfo/sngdate/caldate">
            <field name="dct_temporal_sm">
            <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
            </field>   
            </xsl:when>
            <xsl:when test="idinfo/timeperd/timeinfo/mdattim/sngdate/caldate">
            <field name="dct_temporal_sm">  
              <xsl:value-of select="substring(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate,1,4)"/>
            </field>  
            </xsl:when>
            
            <!-- YYYY-MM, YYYY-MM-DD
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
            
            <!-- content date range: YYYY-YYYY if dates differ -->
            <xsl:when test="idinfo/timeperd/timeinfo/rngdates/begdate/text() != ''">
              <field name="dct_temporal_sm">
              <xsl:value-of select="substring(idinfo/timeperd/timeinfo/rngdates/begdate, 1,4)"/>
              <xsl:if test="substring(idinfo/timeperd/timeinfo/rngdates/begdate,1,4) != substring(idinfo/timeperd/timeinfo/rngdates/enddate,1,4)"> 
              <xsl:text>-</xsl:text>
              <xsl:value-of select="substring(idinfo/timeperd/timeinfo/rngdates/enddate,1,4)"/>
              </xsl:if>
              </field>  
            </xsl:when>
          </xsl:choose>
        
       
        <!-- collection -->
        <xsl:for-each select="idinfo/citation/citeinfo/lworkcit/citeinfo">
        <field name="dct_isPartOf_sm">
          <xsl:value-of select="title"/>
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
          <xsl:text>ENVELOPE((</xsl:text>
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
          <xsl:text>))</xsl:text>
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
      
     
        <field name="solr_bbox">
          <xsl:value-of select="$x1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y1"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$x2"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$y2"/>
        </field>
        
        <field name="solr_sw_pt">
          <xsl:value-of select="$y1"/>
          <xsl:text>,</xsl:text>
          <xsl:value-of select="$x1"/>
        </field>
        
        <field name="solr_ne_pt">
          <xsl:value-of select="$y2"/>
          <xsl:text>,</xsl:text>
          <xsl:value-of select="$x2"/>
        </field>
        
        <!-- content date: singular, or beginning date of range: YYYY -->

            <xsl:choose>
                <xsl:when test="idinfo/timeperd/timeinfo/sngdate/caldate">
                  <field name="solr_year_i">
                    <xsl:value-of select="substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)"/>
                  </field>   
                </xsl:when>
              <xsl:when test="idinfo/timeperd/timeinfo/mdattim/sngdate/caldate">
                <field name="solr_year_i">
                <xsl:value-of select="substring(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate,1,4)"/>
                </field>  
              </xsl:when>
              <xsl:when test="idinfo/timeperd/timeinfo/rngdates/begdate/text() != ''">
                <field name="solr_year_i">
                <xsl:value-of select="substring(idinfo/timeperd/timeinfo/rngdates/begdate, 1,4)"/>
                </field>  
              </xsl:when>
           </xsl:choose>
        
      </doc>
    </add>
  </xsl:template>
       
</xsl:stylesheet>
