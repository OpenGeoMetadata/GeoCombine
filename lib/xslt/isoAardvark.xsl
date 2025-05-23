<!--
iso2aardvark.xsl - Transformation from ISO 19139 XML into Aardvark json
Some fields will require customization at the organizational level (e.g: dct_references_s, schema_provider_s)

-->

<xsl:stylesheet xmlns="http://www.loc.gov/mods/v3" xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmi="http://www.isotc211.org/2005/gmi" xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gml="http://www.opengis.net/gml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="gml gmd gco gmi xsl">
  <xsl:output method="text" encoding="UTF-8" version="1.0" omit-xml-declaration="yes" indent="yes"
    media-type="application/json"/>
  <xsl:strip-space elements="*"/>



  <xsl:template match="/">
        
      <xsl:variable name="upperCorner">
      <xsl:value-of
        select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)"/>
      <xsl:text> </xsl:text>
      <xsl:value-of
        select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)"
      />
    </xsl:variable>

    <xsl:variable name="lowerCorner">
      <xsl:value-of
        select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)"/>
      <xsl:text> </xsl:text>
      <xsl:value-of
        select="number(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)"/>
    </xsl:variable>

      <xsl:variable name="druid">
          <xsl:value-of select=" substring-after(gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString,'purl:')"/>
      </xsl:variable>
    <xsl:variable name="uuid">
      <xsl:value-of select="gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString"/>
    </xsl:variable>
    <xsl:variable name="temporalBegin">
      <xsl:choose>
        <xsl:when
          test="matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T')">
          <xsl:value-of
            select="substring-before(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T')"
          />
        </xsl:when>
        <xsl:when
          test="matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, '^\d{4}-[\d]{2}-[\d]{2}$')">
          <xsl:value-of
            select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition"
          />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="beginDate">
      <xsl:choose>
        <xsl:when
          test=" matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, 'T')">
          <xsl:value-of
            select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition"
          />
        </xsl:when>
        <xsl:when
          test="matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, '^\d{4}-\d{2}-\d{2}$')">
          <xsl:value-of
            select="dateTime(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:beginPosition, xs:time('00:00:00'))"
          />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="endDate">
      <xsl:choose>
        <xsl:when
          test="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition != ''">
          <xsl:value-of
            select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition"
          />
        </xsl:when>
        <xsl:when
          test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimePeriod/gml:endPosition/@indeterminatePosition">
          <xsl:text>?</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="temporalInstance">
      <xsl:choose>
        <xsl:when
          test="count(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition) = 1">
          <xsl:choose>
            <xsl:when
              test="matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition, 'T')">
              <xsl:value-of
                select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition"
              />
            </xsl:when>
            <xsl:when
              test="matches(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition, '^\d{4}-\d{2}-\d{2}$')">
              <xsl:value-of
                select="dateTime(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/gml:TimeInstant/gml:timePosition, xs:time('00:00:00'))"
              />
            </xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="titleDate">
      <xsl:value-of
        select="substring(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString, string-length(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString) - 3)"
      />
    </xsl:variable>
    <xsl:variable name="dateIssued">
      <xsl:value-of
        select="year-from-date(xs:date(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode[text() = 'publication']]/gmd:date/gco:Date))"
      />
    </xsl:variable>

    <xsl:variable name="identifier">
      <xsl:choose>
        <!-- for Stanford URIs -->
        <xsl:when test="contains($uuid, 'purl')">
          <xsl:value-of select="substring($uuid, string-length($uuid) - 10)"/>
        </xsl:when>
        <!-- all others -->
        <xsl:otherwise>
          <xsl:value-of select="$uuid"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- 01. Title. Required. Not repeatable -->
    <xsl:text>{"dct_title_s": "</xsl:text>
    <xsl:value-of
      select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
    <xsl:text>",</xsl:text>
      <!-- 02. Alternative Title. Optional. Repeatable.  -->
      <xsl:if test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
        <xsl:text>"dct_alternative_sm": [</xsl:text>
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:alternateTitle/gco:CharacterString">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
            <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
          <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
      </xsl:if>
      <!-- 03. Description. Recommended. Repeatable -->
      <xsl:if test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract">
      <xsl:text>"dct_description_sm": [</xsl:text>
      <xsl:for-each
        select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
      </xsl:if>
    
    <!-- 04. Language. Optional. Repeatable -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language[not(@gco:nilReason = 'missing')]">
      <xsl:text>"dct_language_sm": [</xsl:text>
      <xsl:for-each
        select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:language">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="gmd:LanguageCode"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    <!-- 05. Creator. Recommended. Repeatable -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue = 'originator']">
      <xsl:text>"dct_creator_sm": [</xsl:text>

      <xsl:for-each
        select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator' and not(gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString | gmd:individualName/gco:CharacterString = preceding-sibling::gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString | gmd:individualName/gco:CharacterString)]">
        <xsl:choose>
          <xsl:when
            test="gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString and gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString"/>
            <xsl:text> (</xsl:text>
            <xsl:if test="gmd:CI_ResponsibleParty/gmd:positionName">
              <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:positionName/gco:CharacterString"/>
            </xsl:if>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
            <xsl:text>)"</xsl:text>
          </xsl:when>
          <xsl:when test="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
            <xsl:text>"</xsl:text>
          </xsl:when>
          <xsl:when test="gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="gmd:CI_ResponsibleParty/gmd:individualName/gco:CharacterString"/>
            <xsl:text>"</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    <!-- 06. Publisher. Recommended. Repeatable -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue = 'publisher']">
      <xsl:text>"dct_publisher_sm": [</xsl:text>
      <xsl:for-each
        select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue = 'publisher']">
        <xsl:if test="ancestor-or-self::*/gmd:organisationName">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="ancestor-or-self::*/gmd:organisationName"/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="ancestor-or-self::*/gmd:individualName">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="ancestor-or-self::*/gmd:individualName"/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    <!-- 07. Provider. Recommended. Not Repeatable. -->

      <xsl:text>"schema_provider_s": "</xsl:text>
      <xsl:value-of select="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/gco:CharacterString"/>
      <xsl:text>",</xsl:text>
    
    <!-- 08. Resource Class. Required. Repeatable up to 5 times.  -->
    <xsl:text>"gbl_resourceClass_sm": ["Datasets"],</xsl:text>
 
      <!-- 09. Resource Type. Recommended -->  
      
    <xsl:if test="//gmd:MD_GeometricObjectTypeCode[@codeListValue][contains(.,'point') or (.,'curve') or (.,'surface')] or //gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString/text()[contains(.,'Raster')]">     
      <xsl:text>"gbl_resourceType_sm": ["</xsl:text>
      </xsl:if>
      <xsl:choose>
          <xsl:when
              test="gmd:MD_Metadata/gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode[@codeListValue = 'surface']">
              <xsl:text>Polygon data</xsl:text>
              <xsl:text>"],</xsl:text>  
          </xsl:when>
        
        <xsl:when
          test="gmd:MD_Metadata/gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode[@codeListValue = 'composite']">
          <xsl:text>Polygon data</xsl:text>
          <xsl:text>"],</xsl:text>  
        </xsl:when>
 
          <xsl:when
              test="gmd:MD_Metadata/gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode[@codeListValue = 'curve']">
              <xsl:text>Line data</xsl:text>
          </xsl:when>

          <xsl:when
              test="gmd:MD_Metadata/gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode[@codeListValue = 'point']">
              <xsl:text>Point data</xsl:text>
               <xsl:text>"],</xsl:text>  
          </xsl:when>
        <xsl:when test="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString/text()[contains(.,'Raster')]">
          <xsl:text>Vector data</xsl:text>
          <xsl:text>"],</xsl:text>  
        </xsl:when>
        <xsl:when test="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString/text()[contains(.,'Raster')]">
          <xsl:text>Raster data</xsl:text>
          <xsl:text>"],</xsl:text>  
        </xsl:when>
      </xsl:choose>  

    <!-- 10. Subject. Optional. Repeatable -->
     
      <xsl:if
          test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue = 'theme']">
          <xsl:text>"dct_subject_sm": [</xsl:text>
          <xsl:for-each
              select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue = 'theme']]">
              <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                  <xsl:text>"</xsl:text>
                  <xsl:value-of select="gco:CharacterString"/>
                  <xsl:text>"</xsl:text>
                  <xsl:if test="position() != last()">
                      <xsl:text>,</xsl:text>
                  </xsl:if>
              </xsl:for-each>
              <xsl:if test="position() != last()">
                  <xsl:text>,</xsl:text>
              </xsl:if>
          </xsl:for-each>
          <xsl:text>],</xsl:text>
      </xsl:if>
    <!-- 11. Theme. Optional. Repeatable -->
      <xsl:if test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
      <xsl:text>"dcat_theme_sm": [</xsl:text>
        <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:topicCategory/gmd:MD_TopicCategoryCode"> 


            <xsl:if test="contains(.,'farming')">
               <xsl:text>"Agriculture"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'biota')">
               <xsl:text>"Biology"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'boundaries')">
                <xsl:text>"Boundaries"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'climatologyMeteorologyAtmosphere')">
                <xsl:text>"Climate"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'economy')">
                <xsl:text>"Economy"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'elevation')">
                <xsl:text>"Elevation"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'environment')">
                <xsl:text>"Environment"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'geoscientificInformation')">
                <xsl:text>"Geology"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'health')">
                <xsl:text>"Health"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'imageryBaseMapsEarthCover')">

                    <xsl:choose>
                    <xsl:when test="//gmd:keyword/gco:CharacterString[contains(.,'Land cover')]">
                        <xsl:text>"Land cover"</xsl:text>
                    </xsl:when>
                        <xsl:when test="//gmd:keyword/gco:CharacterString[contains(.,'photo')]">
                            <xsl:text>"Imagery"</xsl:text>
                        </xsl:when>
                    <xsl:otherwise>
                       <xsl:text>"Imagery"</xsl:text>
                    </xsl:otherwise>
                    </xsl:choose>
            </xsl:if>

            <xsl:if test="contains(.,'inlandWaters')">
                <xsl:text>"Inland waters"</xsl:text>
                
            </xsl:if>
            <xsl:if test="contains(.,'location')">
                <xsl:text>"Location"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'intelligenceMilitary')">
                <xsl:text>"Military"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'oceans')">
                <xsl:text>"Oceans"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'planningCadastre')">
                <xsl:text>"Property"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'society')">
                <xsl:text>"Society"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'structure')">
                <xsl:text>"Structure"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'transportation')">
                <xsl:text>"Transportation"</xsl:text>
            </xsl:if>
            <xsl:if test="contains(.,'utilitiesCommunication')">
                <xsl:text>"Utilities"</xsl:text>
            </xsl:if>
            <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
        </xsl:for-each>
      </xsl:if>


      <xsl:text>],</xsl:text>   
      
      <!-- 12. Keyword. Optional. Repeatable -->
    
    <!-- 13. Temporal Coverage. Recommended. Repeatable -->
    <xsl:choose>
      <xsl:when test="$beginDate != '' and $endDate != ''">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
          <xsl:value-of select="format-dateTime($beginDate, '[Y0001]-[M01]-[D01]')"/>
        <xsl:text> to </xsl:text>
        <xsl:choose>
          <xsl:when test="$endDate = '?'">
            <xsl:value-of select="$endDate"/>
          </xsl:when>
          <xsl:when test="month-from-dateTime($endDate) = 1 and day-from-dateTime($endDate) = 1">
            <xsl:value-of select="year-from-dateTime($endDate)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-dateTime($endDate, '[Y0001]-[M01]-[D01]')"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"],</xsl:text>
      </xsl:when>
      <xsl:when test="$temporalInstance != ''">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:choose>
          <xsl:when
            test="month-from-dateTime($temporalInstance) = 1 and day-from-dateTime($temporalInstance) = 1">
            <xsl:value-of select="year-from-dateTime($temporalInstance)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-dateTime($temporalInstance, '[Y0001]-[M01]-[D01]')"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"],</xsl:text>
      </xsl:when>
      <xsl:when test="not(empty($titleDate))">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:value-of select="$titleDate"/>
        <xsl:text>"],</xsl:text>
      </xsl:when>
      <xsl:when
        test="count(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification//gmd:temporalElement//gml:timePosition) &gt; 1">
        <xsl:text>"dct_temporal_sm": ["</xsl:text>
        <xsl:for-each
          select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification//gmd:temporalElement//gml:timePosition">
          <xsl:choose>
            <xsl:when test="month-from-dateTime(.) = 1 and day-from-dateTime(.) = 1">
              <xsl:value-of select="year-from-dateTime(.)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="format-dateTime(., '[Y0001]-[M01]-[D01]')"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="position() != last() - 1 and position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:when>
            <xsl:when test="position() = last() - 1">
              <xsl:text> and </xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text>"],</xsl:text>
      </xsl:when>
    </xsl:choose>
    <!-- 14. Date Issued. Optional. Not Repeatable -->
    <xsl:if test="$dateIssued != ''">
      <xsl:text>"dct_issued_s": "</xsl:text>
      <xsl:value-of select="$dateIssued"/>
      <xsl:text>",</xsl:text>
    </xsl:if>
    <!-- 15. Index Year. Recommended. Repeatable -->
    <xsl:choose>
      <xsl:when test="$beginDate != '' and $endDate != ''">
        <xsl:text>"gbl_indexYear_im": [</xsl:text>
        <xsl:choose>
          <xsl:when test="$endDate = '?'">
            <xsl:value-of select="year-from-dateTime($beginDate)"/>
            <xsl:text>],</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="year-from-dateTime($beginDate) to year-from-dateTime($endDate)">
              <xsl:value-of select="position() - 1 + year-from-dateTime($beginDate)"/>
              <xsl:if test="position() != last()">
                <xsl:text>,</xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:text>],</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when
        test="count(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent) &gt; 1">
        <xsl:text>"gbl_indexYear_im": [</xsl:text>
        <xsl:for-each
          select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification//gmd:temporalElement//gml:timePosition">
          <xsl:value-of select="year-from-dateTime(.)"/>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>],</xsl:text>
      </xsl:when>
      <xsl:when test="$temporalInstance != ''">
        <xsl:text>"gbl_indexYear_im": [</xsl:text>
        <xsl:value-of select="year-from-dateTime($temporalInstance)"/>
        <xsl:text>],</xsl:text>
      </xsl:when>
      <xsl:when test="$titleDate != ''">
        <xsl:text>"gbl_indexYear_im": [</xsl:text>
        <xsl:value-of select="$titleDate"/>
        <xsl:text>],</xsl:text>
      </xsl:when>
      <xsl:when test="$dateIssued != ''">
        <xsl:text>"gbl_indexYear_im": [</xsl:text>
        <xsl:value-of select="year-from-dateTime($dateIssued)"/>
        <xsl:text>],</xsl:text>
      </xsl:when>
    </xsl:choose>
    <!-- 16. Date Range. Optional. Repeatable -->
    <xsl:choose>
      <xsl:when test="$beginDate != '' and $endDate != '' and $endDate != '?'">
        <xsl:text>"gbl_dateRange_drsim" : "[</xsl:text>
        <xsl:value-of select="year-from-dateTime($beginDate)"/>
        <xsl:text> TO </xsl:text>
        <xsl:value-of select="year-from-dateTime($endDate)"/>
        <xsl:text>]",</xsl:text>
      </xsl:when>
      <xsl:when
        test="count(/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent) &gt; 1">
        <xsl:text>"gbl_dateRange_drsim" : "[</xsl:text>
        <xsl:for-each
          select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification//gmd:temporalElement//gml:timePosition">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <xsl:value-of select="year-from-dateTime(.)"/>
              <xsl:text> TO </xsl:text>
            </xsl:when>
            <xsl:when test="position() = last()">
              <xsl:value-of select="year-from-dateTime(.)"/>
              <xsl:text>]",</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
    <!-- 17. Spatial Coverage. Recommended. Repeatable -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue = 'place']">
      <xsl:text>"dct_spatial_sm": [</xsl:text>
      <xsl:for-each
        select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:type/gmd:MD_KeywordTypeCode[@codeListValue = 'place']]">
        <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="gco:CharacterString"/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="position() != last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],</xsl:text>
    </xsl:if>
    <!-- 18. Geometry. Recommended. Not Repeatable -->
    <xsl:choose>
      <xsl:when
        test="count(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox) = 1">
        <xsl:text>"locn_geometry": "ENVELOPE(</xsl:text>
        <xsl:value-of
          select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of
          select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of
          select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of
          select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/>
        <xsl:text>)",</xsl:text>
      </xsl:when>
      <xsl:when
        test="count(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox) &gt; 1">
        <xsl:text>"locn_geometry": "MULTIPOLYGON(</xsl:text>
        <xsl:for-each
          select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
          <xsl:variable name="e" select="gmd:eastBoundLongitude/gco:Decimal"/>
          <xsl:variable name="w" select="gmd:westBoundLongitude/gco:Decimal"/>
          <xsl:variable name="n" select="gmd:northBoundLatitude/gco:Decimal"/>
          <xsl:variable name="s" select="gmd:southBoundLatitude/gco:Decimal"/>
          <xsl:text>((</xsl:text>
          <xsl:value-of select="$w"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$n"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$e"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$n"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$e"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$s"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="$w"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$s"/>
          <xsl:text>))</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>)",</xsl:text>
      </xsl:when>
    </xsl:choose>

    <!-- 19. Bounding Box. Recommended. Not Repeatable -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
      <xsl:text>"dcat_bbox": "ENVELOPE(</xsl:text>
      <xsl:value-of
        select="min(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal)"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of
        select="max(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal)"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of
        select="max(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal)"/>
      <xsl:text>, </xsl:text>
      <xsl:value-of
        select="min(gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal)"/>
      <xsl:text>)",</xsl:text>
    </xsl:if>
    <!-- 20. Centroid. Optional. Not Repeatable -->
    <!-- 21. Relation. Optional. Repeatable -->
    <!-- 22. Member Of. Optional. Repeatable -->
    
    <xsl:if test="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/associationType/DS_AssociationTypeCode = 'largerWorkCitation'">
        <xsl:text>"pcdm_memberOf_sm": [</xsl:text>
        <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title/gco:CharacterString">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
        <xsl:text>,</xsl:text>
      </xsl:if>
    
    
    <!-- 23. Is Part Of. Optional. Repeatable -->
    <!-- 24. Source. Optional. Repeatable -->
    <!-- 25. Is Version Of. Optional. Repeatable -->
    <!-- 26. Replaces. Optional. Repeatable -->
    <!-- 27. Is Replaced By. Optional. Repeatable -->
    <!-- 28. Rights. Recommended. Not Repeatable. -->
    <xsl:if
      test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString">
      <xsl:text>"dct_rights_sm": ["</xsl:text>
      <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:otherConstraints/gco:CharacterString"/>
      <xsl:text>"],</xsl:text>
    </xsl:if>
    <!-- 29. Rights Holder. Optional. Repeatable -->
    <!-- 30. License. Optional. Repeatable -->
    <!-- 31. Access Rights. Required. Not Repeatable -->
    <xsl:text>"dct_accessRights_s": </xsl:text>
    <xsl:choose>
      <xsl:when
        test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints/gmd:MD_RestrictionCode[@codeListValue = 'restricted']">
        <xsl:text>"Restricted",</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"Public",</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-- 32. Format. Conditional. Not Repeatable.  -->
    <xsl:text>"dct_format_s": "</xsl:text>
    <xsl:choose>
      <xsl:when test="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString='dBASE Table'">
        <xsl:text>Tabular Data</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>",</xsl:text>
    <!-- 33. File Size. Optional. Not Repeatable. -->
    <!-- 34. WxS Identifier. Conditional. Not Repeatable.  -->
    <xsl:text>"gbl_wxsIdentifier_s": "druid:</xsl:text>
    <xsl:value-of select="$identifier"/>
    <xsl:text>",</xsl:text>
    <!-- 35. References. Recommended. Not Repetable.This one is hard to map - may need to be done on an institutional basis.-->

    <!-- 36. ID. Required. Not repeatable -->
    <xsl:text>"id": "</xsl:text>
    <xsl:value-of select="$druid"/>
    <xsl:text>",</xsl:text>
    <!-- 37. Identifier. Recommended. Repeatable.-->
      <xsl:if test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
          <xsl:text>"dct_identifier_sm": ["</xsl:text>
          <xsl:value-of select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString"/>
          <xsl:text>"],</xsl:text>
      </xsl:if>
    <!-- 38. Modified. Required. Not Repeatable. This is when the METADATA is modified, not the resource. -->
    <xsl:text>"gbl_mdModified_dt": "</xsl:text>
    <xsl:value-of
      select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H'))"/>
    <xsl:text>",</xsl:text>
    <!-- 39. Metadata Version. Required. Not Repeatable -->
    <xsl:text>"gbl_mdVersion_s": "Aardvark",</xsl:text>

    <!-- 41. Georeferenced. Optional. Not Repeatable. ]].-->
      
      <!-- collection -->
      <xsl:choose>
          <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='largerWorkCitation']">
              <xsl:text>"pcdm_memberOf_sm" : [</xsl:text>
              <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:associationType/gmd:DS_AssociationTypeCode[@codeListValue='largerWorkCitation']">
                  <xsl:text>"</xsl:text>
                  <xsl:value-of select="ancestor-or-self::*/gmd:aggregateDataSetName/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
                  <xsl:text>"</xsl:text>
              </xsl:for-each>
              <xsl:text>],</xsl:text>
          </xsl:when>
          <xsl:when test="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:collectiveTitle">
              <xsl:for-each select="gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:collectiveTitle">
                  <xsl:text>"pcdm_memberOf_sm" : [</xsl:text>
                  <xsl:text>"</xsl:text>
                      <xsl:value-of select="."/>
                  <xsl:text>"</xsl:text>
              </xsl:for-each>
              <xsl:text>],</xsl:text>
          </xsl:when>
      </xsl:choose>  
      
      <!-- 40. Suppressed. Optional. Not Repeatable -->
      <xsl:text>"gbl_suppressed_b": false}</xsl:text>

  </xsl:template>
 

</xsl:stylesheet>