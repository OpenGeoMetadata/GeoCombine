<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" version="1.0" encoding="UTF-8" media-type="application/json"
    omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="provider" select="''"/>
  <xsl:param name="id" select="''"/>

  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

  <!-- Characters replaced by a hyphen when building a slug. -->
  <xsl:variable name="slugPunctuation">
    <xsl:text> .,:;/\()[]{}"'_+&amp;?!@#$%*=|&lt;&gt;~`^&#9;&#10;&#13;</xsl:text>
  </xsl:variable>
  <xsl:variable name="slugHyphens">
    <xsl:text>-----------------------------------</xsl:text>
  </xsl:variable>

  <!-- ==================================================================
       Helper templates
       ================================================================== -->

  <xsl:template name="replace-substring">
    <xsl:param name="value"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($value, $from)">
        <xsl:value-of select="substring-before($value, $from)"/>
        <xsl:value-of select="$to"/>
        <xsl:call-template name="replace-substring">
          <xsl:with-param name="value" select="substring-after($value, $from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Escape a string for use as a JSON string literal. -->
  <xsl:template name="escape-json">
    <xsl:param name="text"/>
    <xsl:variable name="backslash">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="string($text)"/>
        <xsl:with-param name="from" select="'\'"/>
        <xsl:with-param name="to" select="'\\'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="quote">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="string($backslash)"/>
        <xsl:with-param name="from" select="'&quot;'"/>
        <xsl:with-param name="to" select="'\&quot;'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="carriageReturn">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="string($quote)"/>
        <xsl:with-param name="from" select="'&#13;'"/>
        <xsl:with-param name="to" select="'\r'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="newline">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="string($carriageReturn)"/>
        <xsl:with-param name="from" select="'&#10;'"/>
        <xsl:with-param name="to" select="'\n'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="replace-substring">
      <xsl:with-param name="value" select="string($newline)"/>
      <xsl:with-param name="from" select="'&#9;'"/>
      <xsl:with-param name="to" select="'\t'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Return an escaped and quoted JSON string. -->
  <xsl:template name="json-string">
    <xsl:param name="text"/>
    <xsl:text>"</xsl:text>
    <xsl:call-template name="escape-json">
      <xsl:with-param name="text" select="normalize-space($text)"/>
    </xsl:call-template>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- Return "key": [ ... ], for a set of nodes -->
  <xsl:template name="string-array">
    <xsl:param name="key"/>
    <xsl:param name="nodes"/>
    <xsl:variable name="items">
      <xsl:for-each select="$nodes">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,</xsl:text>
          <xsl:call-template name="json-string">
            <xsl:with-param name="text" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="$key"/>
      <xsl:with-param name="items" select="$items"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Return "key": [ ... ] from a comma-prefixed item list. -->
  <xsl:template name="emit-array">
    <xsl:param name="key"/>
    <xsl:param name="items"/>
    <xsl:if test="string($items) != ''">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$key"/>
      <xsl:text>": [</xsl:text>
      <xsl:value-of select="substring(string($items), 2)"/>
      <xsl:text>],</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Last segment of a delimited string. Used to find the final path element of a URL. -->
  <xsl:template name="substring-after-last">
    <xsl:param name="value"/>
    <xsl:param name="delimiter"/>
    <xsl:choose>
      <xsl:when test="contains($value, $delimiter)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="value" select="substring-after($value, $delimiter)"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="trim-hyphens">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="starts-with($value, '-')">
        <xsl:call-template name="trim-hyphens">
          <xsl:with-param name="value" select="substring($value, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="substring($value, string-length($value)) = '-'">
        <xsl:call-template name="trim-hyphens">
          <xsl:with-param name="value" select="substring($value, 1, string-length($value) - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Convert to slug -->
  <xsl:template name="slugify">
    <xsl:param name="value"/>
    <xsl:variable name="hyphenated"
      select="translate(translate(normalize-space($value), $upper, $lower),
                        string($slugPunctuation), string($slugHyphens))"/>
    <xsl:variable name="collapsed">
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="$hyphenated"/>
        <xsl:with-param name="from" select="'--'"/>
        <xsl:with-param name="to" select="'-'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="trim-hyphens">
      <xsl:with-param name="value" select="string($collapsed)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- FGDC dates are YYYY, YYYYMM or YYYYMMDD. -->
  <xsl:template name="format-date">
    <xsl:param name="value"/>
    <xsl:variable name="date" select="normalize-space($value)"/>
    <xsl:choose>
      <xsl:when test="string-length($date) = 8 and string(number($date)) != 'NaN'">
        <xsl:value-of select="concat(substring($date, 1, 4), '-', substring($date, 5, 2), '-',
                                     substring($date, 7, 2))"/>
      </xsl:when>
      <xsl:when test="string-length($date) = 6 and string(number($date)) != 'NaN'">
        <xsl:value-of select="concat(substring($date, 1, 4), '-', substring($date, 5, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$date"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ==================================================================
       Shared variables
       ================================================================== -->

  <xsl:variable name="west" select="number(/metadata/idinfo/spdom/bounding/westbc)"/>
  <xsl:variable name="east" select="number(/metadata/idinfo/spdom/bounding/eastbc)"/>
  <xsl:variable name="north" select="number(/metadata/idinfo/spdom/bounding/northbc)"/>
  <xsl:variable name="south" select="number(/metadata/idinfo/spdom/bounding/southbc)"/>

  <xsl:variable name="hasBoundingBox"
    select="string($west) != 'NaN' and string($east) != 'NaN' and
            string($north) != 'NaN' and string($south) != 'NaN'"/>

  <xsl:variable name="envelope"
    select="concat('ENVELOPE(', $west, ',', $east, ',', $north, ',', $south, ')')"/>

  <xsl:variable name="providerName">
    <xsl:choose>
      <xsl:when test="normalize-space($provider) != ''">
        <xsl:value-of select="normalize-space($provider)"/>
      </xsl:when>
      <xsl:when test="normalize-space(/metadata/distinfo/distrib/cntinfo/cntorgp/cntorg) != ''">
        <xsl:value-of select="normalize-space(/metadata/distinfo/distrib/cntinfo/cntorgp/cntorg)"/>
      </xsl:when>
      <xsl:when test="normalize-space(/metadata/idinfo/ptcontac/cntinfo/cntorgp/cntorg) != ''">
        <xsl:value-of select="normalize-space(/metadata/idinfo/ptcontac/cntinfo/cntorgp/cntorg)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(/metadata/metainfo/metc/cntinfo/cntorgp/cntorg)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Keywords with GBL controlled vocabulary values. -->
  <xsl:variable name="resourceClassKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'GBL Resource Class']/themekey"/>
  <xsl:variable name="resourceTypeKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'GBL Resource Type']/themekey"/>
  <xsl:variable name="themeKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'ISO GBL Theme']/themekey"/>
  <xsl:variable name="subjectKeywords"
    select="/metadata/idinfo/keywords/theme[not(normalize-space(themekt) = 'GBL Resource Class' or
                                                normalize-space(themekt) = 'GBL Resource Type' or
                                                normalize-space(themekt) = 'ISO GBL Theme')]/themekey"/>

  <xsl:variable name="geoform"
    select="translate(normalize-space(/metadata/idinfo/citation/citeinfo/geoform), $upper, $lower)"/>
  <xsl:variable name="sdtsType"
    select="translate(normalize-space(/metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype), $upper, $lower)"/>
  <xsl:variable name="directReference"
    select="translate(normalize-space(/metadata/spdoinfo/direct), $upper, $lower)"/>
  <xsl:variable name="formatName"
    select="translate(normalize-space(/metadata/distinfo/stdorder/digform/digtinfo/formname), $upper, $lower)"/>

  <!-- ==================================================================
       Record
       ================================================================== -->

  <xsl:template match="/metadata">
    <xsl:text>{</xsl:text>

    <!-- Title (Required) -->
    <xsl:text>"dct_title_s": </xsl:text>
    <xsl:call-template name="json-string">
      <xsl:with-param name="text" select="idinfo/citation/citeinfo/title"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>

    <!-- Description -->
    <xsl:variable name="descriptions">
      <xsl:if test="normalize-space(idinfo/descript/abstract)">
        <xsl:text>,"Abstract: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/descript/abstract)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space(idinfo/descript/purpose)">
        <xsl:text>,"Purpose: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/descript/purpose)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space(idinfo/descript/supplinf)">
        <xsl:text>,"Supplemental information: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/descript/supplinf)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'dct_description_sm'"/>
      <xsl:with-param name="items" select="$descriptions"/>
    </xsl:call-template>

    <!-- Language -->
    <xsl:if test="normalize-space(idinfo/descript/langdata)">
      <xsl:text>"dct_language_sm": [</xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="idinfo/descript/langdata"/>
      </xsl:call-template>
      <xsl:text>],</xsl:text>
    </xsl:if>

    <!-- Creator -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_creator_sm'"/>
      <xsl:with-param name="nodes" select="idinfo/citation/citeinfo/origin"/>
    </xsl:call-template>

    <!-- Publisher -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_publisher_sm'"/>
      <xsl:with-param name="nodes" select="idinfo/citation/citeinfo/pubinfo/publish"/>
    </xsl:call-template>

    <!-- Provider -->
    <xsl:if test="string($providerName) != ''">
      <xsl:text>"schema_provider_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($providerName)"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- Resource Class (Required) -->
    <xsl:variable name="resourceClasses">
      <xsl:choose>
        <xsl:when test="$resourceClassKeywords[normalize-space(.)]">
          <xsl:for-each select="$resourceClassKeywords">
            <xsl:if test="normalize-space(.)">
              <xsl:text>,</xsl:text>
              <xsl:call-template name="json-string">
                <xsl:with-param name="text" select="."/>
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="contains($geoform, 'remote-sensing image')">
          <xsl:text>,"Imagery"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($geoform, 'digital data')">
          <xsl:text>,"Datasets"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($geoform, 'web service')">
          <xsl:text>,"Web services"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($geoform, 'website')">
          <xsl:text>,"Websites"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($geoform, 'collection')">
          <xsl:text>,"Collections"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($geoform, 'map') or contains($geoform, 'atlas')">
          <xsl:text>,"Maps"</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>,"Other"</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'gbl_resourceClass_sm'"/>
      <xsl:with-param name="items" select="$resourceClasses"/>
    </xsl:call-template>

    <!-- Resource Type -->
    <xsl:variable name="resourceTypes">
      <xsl:choose>
        <xsl:when test="$resourceTypeKeywords[normalize-space(.)]">
          <xsl:for-each select="$resourceTypeKeywords">
            <xsl:if test="normalize-space(.)">
              <xsl:text>,</xsl:text>
              <xsl:call-template name="json-string">
                <xsl:with-param name="text" select="."/>
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="contains($sdtsType, 'polygon')">
          <xsl:text>,"Polygon data"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($sdtsType, 'point') or contains($sdtsType, 'node')">
          <xsl:text>,"Point data"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($sdtsType, 'string') or contains($sdtsType, 'chain') or
                        contains($sdtsType, 'arc') or contains($sdtsType, 'link') or
                        contains($sdtsType, 'line')">
          <xsl:text>,"Line data"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($directReference, 'raster')">
          <xsl:text>,"Raster data"</xsl:text>
        </xsl:when>
        <xsl:when test="contains($directReference, 'point')">
          <xsl:text>,"Point data"</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'gbl_resourceType_sm'"/>
      <xsl:with-param name="items" select="$resourceTypes"/>
    </xsl:call-template>

    <!-- Subject -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_subject_sm'"/>
      <xsl:with-param name="nodes" select="$subjectKeywords"/>
    </xsl:call-template>

    <!-- Theme -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dcat_theme_sm'"/>
      <xsl:with-param name="nodes" select="$themeKeywords"/>
    </xsl:call-template>

    <!-- Temporal Coverage. Ranges are rendered YYYY-YYYY. -->
    <xsl:variable name="temporals">
      <xsl:for-each select="idinfo/timeperd/timeinfo/sngdate/caldate |
                            idinfo/timeperd/timeinfo/mdattim/sngdate/caldate">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,"</xsl:text>
          <xsl:value-of select="substring(normalize-space(.), 1, 4)"/>
          <xsl:text>"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
        <xsl:if test="normalize-space(begdate)">
          <xsl:text>,"</xsl:text>
          <xsl:value-of select="substring(normalize-space(begdate), 1, 4)"/>
          <xsl:if test="substring(normalize-space(begdate), 1, 4) !=
                        substring(normalize-space(enddate), 1, 4) and normalize-space(enddate)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring(normalize-space(enddate), 1, 4)"/>
          </xsl:if>
          <xsl:text>"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="idinfo/keywords/temporal/tempkey">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,</xsl:text>
          <xsl:call-template name="json-string">
            <xsl:with-param name="text" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'dct_temporal_sm'"/>
      <xsl:with-param name="items" select="$temporals"/>
    </xsl:call-template>

    <!-- Date Issued -->
    <xsl:if test="normalize-space(idinfo/citation/citeinfo/pubdate)">
      <xsl:text>"dct_issued_s": "</xsl:text>
      <xsl:call-template name="format-date">
        <xsl:with-param name="value" select="idinfo/citation/citeinfo/pubdate"/>
      </xsl:call-template>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!-- Index Year -->
    <xsl:variable name="indexYears">
      <xsl:choose>
        <xsl:when test="string(number(substring(normalize-space(idinfo/timeperd/timeinfo/sngdate/caldate), 1, 4))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="substring(normalize-space(idinfo/timeperd/timeinfo/sngdate/caldate), 1, 4)"/>
        </xsl:when>
        <xsl:when test="string(number(substring(normalize-space(idinfo/timeperd/timeinfo/mdattim/sngdate[1]/caldate), 1, 4))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="substring(normalize-space(idinfo/timeperd/timeinfo/mdattim/sngdate[1]/caldate), 1, 4)"/>
        </xsl:when>
        <xsl:when test="string(number(substring(normalize-space(idinfo/timeperd/timeinfo/rngdates/begdate), 1, 4))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="substring(normalize-space(idinfo/timeperd/timeinfo/rngdates/begdate), 1, 4)"/>
        </xsl:when>
        <xsl:when test="string(number(normalize-space(idinfo/keywords/temporal/tempkey[1]))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="normalize-space(idinfo/keywords/temporal/tempkey[1])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'gbl_indexYear_im'"/>
      <xsl:with-param name="items" select="$indexYears"/>
    </xsl:call-template>

    <!-- Date Range. A Solr date range string. -->
    <xsl:variable name="dateRanges">
      <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
        <xsl:variable name="begin" select="substring(normalize-space(begdate), 1, 4)"/>
        <xsl:variable name="end" select="substring(normalize-space(enddate), 1, 4)"/>
        <xsl:if test="string(number($begin)) != 'NaN' and string(number($end)) != 'NaN'">
          <xsl:text>,"[</xsl:text>
          <xsl:value-of select="$begin"/>
          <xsl:text> TO </xsl:text>
          <xsl:value-of select="$end"/>
          <xsl:text>]"</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'gbl_dateRange_drsim'"/>
      <xsl:with-param name="items" select="$dateRanges"/>
    </xsl:call-template>

    <!-- Spatial Coverage -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_spatial_sm'"/>
      <xsl:with-param name="nodes" select="idinfo/keywords/place/placekey"/>
    </xsl:call-template>

    <!-- Geometry (Required) -->
    <xsl:if test="$hasBoundingBox">
      <xsl:text>"locn_geometry": "</xsl:text>
      <xsl:value-of select="$envelope"/>
      <xsl:text>",</xsl:text>

      <!-- Bounding Box -->
      <xsl:text>"dcat_bbox": "</xsl:text>
      <xsl:value-of select="$envelope"/>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!-- Is Part Of -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_isPartOf_sm'"/>
      <xsl:with-param name="nodes" select="idinfo/citation/citeinfo/lworkcit/citeinfo/title"/>
    </xsl:call-template>

    <!-- Source -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_source_sm'"/>
      <xsl:with-param name="nodes" select="dataqual/lineage/srcinfo/srccite/citeinfo/title"/>
    </xsl:call-template>

    <!-- Rights -->
    <xsl:variable name="rights">
      <xsl:if test="normalize-space(idinfo/useconst)">
        <xsl:text>,"Use constraints: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/useconst)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space(idinfo/accconst)">
        <xsl:text>,"Access constraints: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/accconst)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space(idinfo/datacred)">
        <xsl:text>,"Data credit: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space(idinfo/datacred)"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'dct_rights_sm'"/>
      <xsl:with-param name="items" select="$rights"/>
    </xsl:call-template>

    <!-- Access Rights -->
    <xsl:variable name="accessConstraints"
      select="translate(normalize-space(idinfo/accconst), $upper, $lower)"/>
    <xsl:variable name="useConstraints"
      select="translate(normalize-space(idinfo/useconst), $upper, $lower)"/>
    <xsl:text>"dct_accessRights_s": "</xsl:text>
    <xsl:choose>
      <xsl:when test="contains($accessConstraints, 'unrestricted')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="contains($accessConstraints, 'restricted')">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with($accessConstraints, 'none') or
                      contains($accessConstraints, 'no restriction') or
                      contains($accessConstraints, 'public domain') or
                      contains($accessConstraints, 'publicly available')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="$accessConstraints = '' and contains($useConstraints, 'unrestricted')">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:when test="$accessConstraints = '' and
                      (starts-with($useConstraints, 'none') or
                       contains($useConstraints, 'no restriction'))">
        <xsl:text>Public</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Restricted</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>",</xsl:text>

    <!-- Format  -->
    <xsl:variable name="format">
      <xsl:choose>
        <xsl:when test="contains($formatName, 'geotiff')">GeoTIFF</xsl:when>
        <xsl:when test="contains($formatName, 'jpeg2000') or contains($formatName, 'jp2')">JPEG2000</xsl:when>
        <xsl:when test="contains($formatName, 'geojson')">GeoJSON</xsl:when>
        <xsl:when test="contains($formatName, 'geodatabase')">File Geodatabase</xsl:when>
        <xsl:when test="contains($formatName, 'shape')">Shapefile</xsl:when>
        <xsl:when test="contains($formatName, 'tiff')">GeoTIFF</xsl:when>
        <xsl:when test="contains($formatName, 'jpeg') or contains($formatName, 'jpg')">JPEG</xsl:when>
        <xsl:when test="contains($formatName, 'png')">PNG</xsl:when>
        <xsl:when test="contains($formatName, 'pdf')">PDF</xsl:when>
        <xsl:when test="contains($formatName, 'arcgrid') or contains($formatName, 'grid')">ArcGRID</xsl:when>
        <xsl:when test="contains($formatName, 'csv')">CSV</xsl:when>
        <xsl:when test="contains($geoform, 'raster digital data')">GeoTIFF</xsl:when>
        <xsl:when test="contains($geoform, 'vector digital data')">Shapefile</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string($format) != ''">
      <xsl:text>"dct_format_s": "</xsl:text>
      <xsl:value-of select="$format"/>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!-- File Size -->
    <xsl:if test="normalize-space(distinfo/stdorder/digform/digtinfo/transize)">
      <xsl:text>"gbl_fileSize_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="distinfo/stdorder/digform/digtinfo/transize[1]"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- ID (Required) -->
    <xsl:variable name="localName">
      <xsl:choose>
        <xsl:when test="normalize-space(spdoinfo/ptvctinf/sdtsterm/@Name)">
          <xsl:value-of select="normalize-space(spdoinfo/ptvctinf/sdtsterm/@Name)"/>
        </xsl:when>
        <xsl:when test="normalize-space(idinfo/citation/citeinfo/onlink)">
          <xsl:call-template name="substring-after-last">
            <xsl:with-param name="value" select="normalize-space(idinfo/citation/citeinfo/onlink)"/>
            <xsl:with-param name="delimiter" select="'/'"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="localSlug">
      <xsl:call-template name="slugify">
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="string($localName) != ''">
              <xsl:value-of select="string($localName)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="idinfo/citation/citeinfo/title"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="providerSlug">
      <xsl:call-template name="slugify">
        <xsl:with-param name="value" select="string($providerName)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>"id": "</xsl:text>
    <xsl:choose>
      <xsl:when test="normalize-space($id) != ''">
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space($id)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string($providerSlug) = '' or
                      starts-with(string($localSlug), concat(string($providerSlug), '-'))">
        <xsl:value-of select="$localSlug"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(string($providerSlug), '-', string($localSlug))"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>",</xsl:text>

    <!-- Modified -->
    <xsl:variable name="modified" select="normalize-space(metainfo/metd)"/>
    <xsl:if test="string-length($modified) &gt;= 4 and string(number($modified)) != 'NaN'">
      <xsl:text>"gbl_mdModified_dt": "</xsl:text>
      <xsl:value-of select="substring($modified, 1, 4)"/>
      <xsl:text>-</xsl:text>
      <xsl:choose>
        <xsl:when test="string-length($modified) &gt;= 6">
          <xsl:value-of select="substring($modified, 5, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>01</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>-</xsl:text>
      <xsl:choose>
        <xsl:when test="string-length($modified) &gt;= 8">
          <xsl:value-of select="substring($modified, 7, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>01</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>T00:00:00Z",</xsl:text>
    </xsl:if>

    <!-- Metadata Version (Required) -->
    <xsl:text>"gbl_mdVersion_s": "Aardvark"</xsl:text>

    <xsl:text>}</xsl:text>
  </xsl:template>
</xsl:stylesheet>
