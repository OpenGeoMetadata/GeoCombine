<?xml version="1.0" encoding="UTF-8"?>
<!--
     fgdc2Aardvark.xsl - Transformation from FGDC into Aardvark solr
        -modified from fgdc2geoBL.xsl
        -updates include:
          -re-ordering of elements according to Aardvark element numbering scheme
        
  ****  WARNING: working DRAFT in progress as of 9/16/2022 ****
          -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
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
      <xsl:text>GeoTIFF</xsl:text>
    </xsl:when>
      <xsl:when test="contains(metadata/idinfo/citation/citeinfo/geoform, 'vector digital data')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'TIFF')">
        <xsl:text>GeoTIFF</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'JPEG2000')">
        <xsl:text>image/jpeg</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/distinfo/stdorder/digform/digtinfo/formname, 'Shape')">
        <xsl:text>Shapefile</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!-- legacy uuid variable
    
    logic needs to be updated for more institutions; used with Aardvark ID -->
  <xsl:variable name="uuid">
    <xsl:choose>
      <xsl:when test="$institution = 'Harvard'">
        <xsl:value-of select="substring-after(metadata/idinfo/citation/citeinfo/onlink, 'harvard-')"/>
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
    <xsl:text>{</xsl:text>
    
    <!-- Title -->
    <xsl:text>"dct_title_s": "</xsl:text>
    <xsl:value-of select="idinfo/citation/citeinfo/title"/>
    <xsl:text>",</xsl:text>

    <!-- Description -->
    <xsl:text>"dct_description_sm": "</xsl:text>
    <xsl:value-of select="idinfo/descript/abstract"/>
    <xsl:text>",</xsl:text>
    
    <!-- Language 
       This is not technically an FGDC element though sometimes appears in the ESRI FGDC Profile schema. Leave in crosswalk? -->
    <xsl:if test="contains(idinfo/descript/langdata, 'en')">
      <xsl:text>"dct_language_sm": "</xsl:text>
      <xsl:text>English</xsl:text>
      <xsl:text>",</xsl:text>
    </xsl:if>
    
    <!-- Creator -->
    <xsl:if test="idinfo/citation/citeinfo/origin">
      <xsl:text>"dct_creator_sm": [</xsl:text>
      <xsl:for-each select="idinfo/citation/citeinfo/origin">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    
    <!-- Publisher -->
    <xsl:if test="idinfo/citation/citeinfo/pubinfo/publish">
      <xsl:text>"dct_publisher_sm": [</xsl:text>
      <xsl:for-each select="idinfo/citation/citeinfo/pubinfo/publish">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    
    <!-- Provider
        $institution variable setting logic should be updated to include more GBL institutions or modified for local use -->
    <xsl:text>"schema_provider_s": "</xsl:text>
    <xsl:value-of select="$institution"/>
    <xsl:text>",</xsl:text>
    
    <!-- Resource Class 
      
      from FGDC <geoform> ; this is a super rudimentary mapping
      between the most common FGDC geoform domain values (which can also be free text) and GBL values;
      "Collections" "Web services" and "Websites" aren't in the FGDC geoforms values list; best practice
      might be to add <themekey> elements for the gbl resourceClass values directly in FGDC and add
      a mapping for this to the xsl, alternately one could use "collections" "web services" or "websites" in the 
      FGDC <geoform> element when applicable and this xsl draft includes those mappings to GBL; 
      also FGDC geoform is a single value, whereas resourceClass may have multivalues -->
    
    <xsl:choose>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'vector digital data')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Datasets</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'raster digital data')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Datasets</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'tabular digital data')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Datasets</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'digital data')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Datasets</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'map')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Maps</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>      
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'remote-sensing image')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Imagery</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'collection')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Collections</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'web service')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Web services</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(/metadata/idinfo/citation/citeinfo/geoform, 'website')">
        <xsl:text>"gbl_resourceClass_sm": "</xsl:text>
        <xsl:text>Websites</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"gbl_resourceClass_sm": "Other",</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- Resource Type -->
    
    <!-- Deprecated element - most closely related to Aardvark Resource Type remove section?
    <xsl:choose>
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'G-polygon')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Polygon</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'Entity point')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Point</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>      
      <xsl:when test="contains(metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype, 'String')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Line</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
      <xsl:when test="contains(metadata/spdoinfo/direct, 'Raster')">
        <xsl:text>"layer_geom_type_s": "</xsl:text>
        <xsl:text>Raster</xsl:text>
        <xsl:text>",</xsl:text>
      </xsl:when>
    </xsl:choose>
    -->
    
    <!-- Subject 
        this could be updated to exclude ISO topics which would then go into dcat_theme_sm -->
    <xsl:if test="idinfo/keywords/theme/themekey">
      <xsl:text>"dct_subject_sm": [</xsl:text>
      <xsl:for-each select="idinfo/keywords/theme/themekey">
        <xsl:if test="not(themekt = 'FGDC')">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    
    <!-- Temporal Coverage -->
    
    <!-- singular content date: YYYY -->
    <xsl:for-each select="idinfo/timeperd/timeinfo/sngdate/caldate">
      <xsl:if test="text() !='' ">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:value-of select="substring(.,1,4)"/>
        <xsl:text>"],</xsl:text>
      </xsl:if>
    </xsl:for-each>
    
    <xsl:for-each select="idinfo/timeperd/timeinfo/mdattim/sngdate">
      <xsl:text>"dct_temporal_sm": ["</xsl:text>
      <xsl:value-of select="substring(caldate,1,4)"/>
      <xsl:text>"],</xsl:text>
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
      <xsl:text>"dct_temporal_sm": ["</xsl:text>
      <xsl:value-of select="substring(begdate, 1,4)"/>
      <xsl:if test="substring(begdate,1,4) != substring(enddate,1,4)">
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(enddate,1,4)"/>
      </xsl:if>
      <xsl:text>"],</xsl:text>
    </xsl:for-each>
    
    <xsl:for-each select="idinfo/keywords/temporal/tempkey">
      <xsl:if test="text() != substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4)">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"],</xsl:text>
      </xsl:if>
    </xsl:for-each>
    
    <!-- Date Issued -->
    <xsl:choose>
      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=4">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="idinfo/citation/citeinfo/pubdate"/>
        <xsl:text>",</xsl:text>
      </xsl:when>
      
      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=6">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>
        <xsl:text>",</xsl:text>
      </xsl:when>
      
      <xsl:when test="string-length(idinfo/citation/citeinfo/pubdate)=8">
        <xsl:text>"dct_issued_s": "</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,5,2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(idinfo/citation/citeinfo/pubdate,7,2)"/>
        <xsl:text>",</xsl:text>
      </xsl:when>
    </xsl:choose>

    <!-- Index Year
        content date for solr year: choose singular, or beginning date of range: YYYY 
        Original xsl source section replaced with section from Harvard fgdc2geoBL.xsl and updated for Aardvark -->
    <xsl:if test="idinfo/timeperd/timeinfo">
      <xsl:choose>
        <xsl:when test="(idinfo/timeperd/timeinfo/sngdate/caldate/text() != '') and (string(number(idinfo/timeperd/timeinfo/sngdate/caldate)) != 'NaN')">
          <xsl:text>"gbl_indexYear_im": </xsl:text>
          <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/sngdate/caldate,1,4), 0)"/>
        </xsl:when>
        
        <xsl:when test="(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate/text() != '') and (string(number(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate)) != 'NaN')">
          <xsl:if test="position() = 1">
            <xsl:text>"gbl_indexYear_im": </xsl:text>
            <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/mdattim/sngdate/caldate,1,4), 0)"/>
          </xsl:if>
        </xsl:when>
        
        <xsl:when test="(idinfo/timeperd/timeinfo/rngdates/begdate/text() != '') and (string(number(idinfo/timeperd/timeinfo/rngdates/begdate)) != 'NaN')">
          <xsl:if test="position() = 1">
            <xsl:text>"gbl_indexYear_im": </xsl:text>
            <xsl:value-of select="format-number(substring(idinfo/timeperd/timeinfo/rngdates/begdate, 1,4), 0)"/>
          </xsl:if>
        </xsl:when>
        
        <xsl:when test="//metadata/idinfo/keywords/temporal/tempkey/text() != '' and (string(number(//metadata/idinfo/keywords/temporal/tempkey)) != 'NaN')">
          <xsl:for-each select="//metadata/idinfo/keywords/temporal/tempkey[1]">
            <xsl:if test="text() != ''">
              <xsl:text>"gbl_indexYear_im": </xsl:text>
              <xsl:value-of select="format-number(., 0)"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        
        <!--  Not sure if the following comment still applies to Aardvark - marc
          currently the schema is built so one has to have a solr_year_i setting to a non real value for cleanup-->
        <xsl:otherwise>
          <xsl:text>"gbl_indexYear_im": 9999</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- Date Range
        added this element for Aardvark, double check logic -->
    <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
      <xsl:text>"gbl_dateRange_drsim": ["[</xsl:text>
      <xsl:value-of select="substring(begdate, 1,4)"/>
      <xsl:if test="substring(begdate,1,4) != substring(enddate,1,4)">
        <xsl:text> TO </xsl:text>
        <xsl:value-of select="substring(enddate,1,4)"/>
      </xsl:if>
      <xsl:text>]"],</xsl:text>
    </xsl:for-each>

    <!-- Spatial Coverage -->
    <xsl:if test="idinfo/keywords/place/placekey">
      <xsl:text>"dct_spatial_sm": [</xsl:text>
      <xsl:for-each select="idinfo/keywords/place/placekey">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    
    <!-- Geometry 
      FGDC records only the bounding box coodinates in metadata standard; could derive more complex geometries from spatial data file -->
    <xsl:text>"locn_geometry": "ENVELOPE(</xsl:text>
    <xsl:value-of select="$x1"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$x2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y1"/>
    <xsl:text>)",</xsl:text>
    
    <!-- Bounding Box -->
    <xsl:text>"dcat_bbox": "ENVELOPE(</xsl:text>
    <xsl:value-of select="$x1"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$x2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y2"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$y1"/>
    <xsl:text>)",</xsl:text>
    
    <!-- Rights -->
    
    <!-- Access Rights
      
      idinfo/acconst is a free text field, so there would have to be some consistency in the coding in this field for a convesion to work reliably. 
      e.g. first word either "Public" or "Restricted" as best practice; 
      current xsl has some logic to identify and populate the gbl value but may not capture all variations  
      -->
    <xsl:text>"dct_accessRights_s": "</xsl:text>
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
    <xsl:text>",</xsl:text>
    
    <!-- Format -->
    <xsl:text>"dct_format_s": "</xsl:text>
    <xsl:value-of select="$format"/>
    <xsl:text>",</xsl:text>
    
    <!-- File Size 
        default is to take the first occurance of the <transize> value; 
        could build-in a check for MB (FGDC specifies MD values for this element) -->
    <xsl:if test="distinfo/stdorder/digform/digtinfo/transize">
      <xsl:text>"gbl_fileSize_s": "</xsl:text>
      <xsl:value-of select="distinfo/stdorder/digform/digtinfo/transize"/>
      <xsl:text>",</xsl:text>
    </xsl:if>
    
    
    <!-- WxS Identifier
      
     legacy code below for layer_id_s:
     
    <xsl:text>"gbl_wxsIdentifier_s": "</xsl:text>
    <xsl:text>urn:</xsl:text>
    <xsl:value-of select="$uuid"/>
    <xsl:text>",</xsl:text>
     -->

    <!-- References - legacy xsl code here; keep?

          <field name="dct_references_s">
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
    
    <!-- ID -->
    <xsl:text>"id": "</xsl:text>
    <xsl:value-of select="$institution"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$uuid"/>
    <xsl:text>",</xsl:text>
    
    <!-- Identifier  
    
    the nature of this element has changed with Aardvark; the definition
    of identifier is now broader so this following legacy transformation is no
    no longer useful; no specific identifier fields exist within FGDC
    
    <xsl:text>"dct_identifier_s": "</xsl:text>
    <xsl:value-of select="idinfo/citation/citeinfo/onlink"/>
    <xsl:text>",</xsl:text>
     -->

    <!-- Modified -->
    <xsl:choose>
      <xsl:when test="string-length(metainfo/metd)=4">
        <xsl:text>"gbl_mdModified_dt": "</xsl:text>
        <xsl:value-of select="metainfo/metd"/>
        <xsl:text>",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(metainfo/metd)=6">
        <xsl:text>"gbl_mdModified_dt": "</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,5,2)"/>
        <xsl:text>",</xsl:text>
      </xsl:when>

      <xsl:when test="string-length(metainfo/metd)=8">
        <xsl:text>"gbl_mdModified_dt": "</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,1,4)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,5,2)"/>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="substring(metainfo/metd,7,2)"/>
        <xsl:text>T12:00:00Z",</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:text>"gbl_mdVersion_s": "Aardvark"</xsl:text>
    
    <xsl:text>}</xsl:text>
   </xsl:template>
</xsl:stylesheet>