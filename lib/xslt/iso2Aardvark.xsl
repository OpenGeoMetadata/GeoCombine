<?xml version="1.0" encoding="UTF-8"?>
<!--
  iso2Aardvark.xsl - Transformation from ISO 19139 XML into OGM Aardvark JSON.

  Written against XSLT 1.0 so that it runs under libxslt (and so Nokogiri).
  Accepts both gmd:MD_Metadata and gmi:MI_Metadata (ISO 19115-2) records.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:gmd="http://www.isotc211.org/2005/gmd"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmi="http://www.isotc211.org/2005/gmi"
  xmlns:gmx="http://www.isotc211.org/2005/gmx"
  xmlns:srv="http://www.isotc211.org/2005/srv"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="gmd gco gmi gmx srv xlink">
  <xsl:output method="text" version="1.0" encoding="UTF-8" media-type="application/json"
    omit-xml-declaration="yes"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="provider" select="''"/>
  <xsl:param name="id" select="''"/>

  <xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  <xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="digits" select="'0123456789'"/>
  <xsl:variable name="nines" select="'9999999999'"/>

  <!-- Characters replaced by a hyphen when building a slug. -->
  <xsl:variable name="slugPunctuation">
    <xsl:text> .,:;/\()[]{}"'_+&amp;?!@#$%*=|&lt;&gt;~`^&#9;&#10;&#13;</xsl:text>
  </xsl:variable>
  <xsl:variable name="slugHyphens">
    <xsl:text>-----------------------------------</xsl:text>
  </xsl:variable>

  <!-- Characters that end a sentence rather than a URI written out in one. -->
  <xsl:variable name="trailingPunctuation">
    <xsl:text>.,;:)]"'</xsl:text>
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

  <xsl:template name="value-list">
    <xsl:param name="nodes"/>
    <xsl:for-each select="$nodes">
      <xsl:if test="normalize-space(.)">
        <xsl:value-of select="concat('&#10;', normalize-space(.))"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="dedupe-values">
    <xsl:param name="values"/>
    <xsl:param name="seen" select="'&#10;'"/>
    <xsl:variable name="list" select="string($values)"/>
    <xsl:if test="$list != ''">
      <xsl:variable name="rest" select="substring($list, 2)"/>
      <xsl:variable name="head">
        <xsl:choose>
          <xsl:when test="contains($rest, '&#10;')">
            <xsl:value-of select="substring-before($rest, '&#10;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$rest"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="tail" select="substring($list, string-length($head) + 2)"/>
      <xsl:choose>
        <xsl:when test="contains($seen, concat('&#10;', string($head), '&#10;'))">
          <xsl:call-template name="dedupe-values">
            <xsl:with-param name="values" select="$tail"/>
            <xsl:with-param name="seen" select="$seen"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('&#10;', string($head))"/>
          <xsl:call-template name="dedupe-values">
            <xsl:with-param name="values" select="$tail"/>
            <xsl:with-param name="seen" select="concat($seen, string($head), '&#10;')"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="json-items">
    <xsl:param name="values"/>
    <xsl:variable name="list" select="string($values)"/>
    <xsl:if test="$list != ''">
      <xsl:variable name="rest" select="substring($list, 2)"/>
      <xsl:variable name="head">
        <xsl:choose>
          <xsl:when test="contains($rest, '&#10;')">
            <xsl:value-of select="substring-before($rest, '&#10;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$rest"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>,</xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($head)"/>
      </xsl:call-template>
      <xsl:call-template name="json-items">
        <xsl:with-param name="values" select="substring($list, string-length($head) + 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="emit-values-array">
    <xsl:param name="key"/>
    <xsl:param name="values"/>
    <xsl:variable name="unique">
      <xsl:call-template name="dedupe-values">
        <xsl:with-param name="values" select="$values"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="items">
      <xsl:call-template name="json-items">
        <xsl:with-param name="values" select="$unique"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="$key"/>
      <xsl:with-param name="items" select="$items"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="string-array">
    <xsl:param name="key"/>
    <xsl:param name="nodes"/>
    <xsl:variable name="values">
      <xsl:call-template name="value-list">
        <xsl:with-param name="nodes" select="$nodes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="$key"/>
      <xsl:with-param name="values" select="$values"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="vocab-value">
    <xsl:param name="vocab"/>
    <xsl:param name="value"/>
    <xsl:variable name="key"
      select="concat('|', translate(normalize-space($value), $upper, $lower), '=')"/>
    <xsl:if test="contains($vocab, $key)">
      <xsl:value-of select="substring-before(substring-after($vocab, $key), '|')"/>
    </xsl:if>
  </xsl:template>

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

  <!-- Collapse runs of hyphens, however long, into one. -->
  <xsl:template name="collapse-hyphens">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="contains($value, '--')">
        <xsl:call-template name="collapse-hyphens">
          <xsl:with-param name="value"
            select="concat(substring-before($value, '--'), '-', substring-after($value, '--'))"/>
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
      <xsl:call-template name="collapse-hyphens">
        <xsl:with-param name="value" select="$hyphenated"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="trim-hyphens">
      <xsl:with-param name="value" select="string($collapsed)"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    The date part of an ISO date or date-time, at whatever precision the source
    records: YYYY, YYYY-MM or YYYY-MM-DD.
  -->
  <xsl:template name="format-date">
    <xsl:param name="value"/>
    <xsl:variable name="date" select="normalize-space($value)"/>
    <xsl:choose>
      <xsl:when test="contains($date, 'T')">
        <xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$date"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- The year of an ISO date or date-time, or nothing if it doesn't start with one. -->
  <xsl:template name="year">
    <xsl:param name="value"/>
    <xsl:variable name="date" select="normalize-space($value)"/>
    <xsl:variable name="next" select="substring($date, 5, 1)"/>
    <xsl:if test="translate(substring($date, 1, 4), $digits, $nines) = '9999' and
                  ($next = '' or $next = '-' or $next = 'T')">
      <xsl:value-of select="substring($date, 1, 4)"/>
    </xsl:if>
  </xsl:template>

  <!--
    Every year from $from to $to, newline delimited. Splits the range in half
    on each call so a long range doesn't run into the recursion limit.
  -->
  <xsl:template name="year-range">
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="$from = $to">
        <xsl:value-of select="concat('&#10;', $from)"/>
      </xsl:when>
      <xsl:when test="$from &lt; $to">
        <xsl:variable name="middle" select="floor(($from + $to) div 2)"/>
        <xsl:call-template name="year-range">
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$middle"/>
        </xsl:call-template>
        <xsl:call-template name="year-range">
          <xsl:with-param name="from" select="$middle + 1"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- The name of a CI_ResponsibleParty, preferring the person or the organisation. -->
  <xsl:template name="party-name">
    <xsl:param name="party"/>
    <xsl:param name="prefer" select="'individual'"/>
    <xsl:variable name="individual" select="normalize-space($party/gmd:individualName/*[1])"/>
    <xsl:variable name="organisation" select="normalize-space($party/gmd:organisationName/*[1])"/>
    <xsl:choose>
      <xsl:when test="$prefer = 'individual' and $individual != ''">
        <xsl:value-of select="concat('&#10;', $individual)"/>
      </xsl:when>
      <xsl:when test="$organisation != ''">
        <xsl:value-of select="concat('&#10;', $organisation)"/>
      </xsl:when>
      <xsl:when test="$individual != ''">
        <xsl:value-of select="concat('&#10;', $individual)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- A service URL with its query string removed. -->
  <xsl:template name="endpoint">
    <xsl:param name="url"/>
    <xsl:variable name="value" select="normalize-space($url)"/>
    <xsl:choose>
      <xsl:when test="contains($value, '?')">
        <xsl:value-of select="substring-before($value, '?')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="trim-trailing-punctuation">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="$value != '' and contains($trailingPunctuation, substring($value, string-length($value)))">
        <xsl:call-template name="trim-trailing-punctuation">
          <xsl:with-param name="value" select="substring($value, 1, string-length($value) - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    The first license URI on $domain in a piece of text, whether the text is the
    URI itself or a sentence containing it. Newline prefixed, or nothing.
  -->
  <xsl:template name="license-uri">
    <xsl:param name="text"/>
    <xsl:param name="domain"/>
    <xsl:variable name="path" select="substring-before(concat(substring-after($text, $domain), ' '), ' ')"/>
    <xsl:if test="starts-with($path, 'licenses/') or starts-with($path, 'publicdomain/')">
      <!-- Whatever is attached to the front of the domain, such as "https://www." -->
      <xsl:variable name="prefix">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="value" select="substring-before($text, $domain)"/>
          <xsl:with-param name="delimiter" select="' '"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:text>&#10;</xsl:text>
      <xsl:choose>
        <xsl:when test="contains($prefix, 'http')">
          <xsl:value-of select="concat('http', substring-after($prefix, 'http'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>https://</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$domain"/>
      <xsl:call-template name="trim-trailing-punctuation">
        <xsl:with-param name="value" select="$path"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- A "key":"url" member of dct_references_s, with a leading comma. -->
  <xsl:template name="reference">
    <xsl:param name="key"/>
    <xsl:param name="url"/>
    <xsl:if test="normalize-space($url) != ''">
      <xsl:text>,"</xsl:text>
      <xsl:value-of select="$key"/>
      <xsl:text>":</xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="$url"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ==================================================================
       Shared variables
       ================================================================== -->

  <xsl:variable name="record" select="/gmd:MD_Metadata | /gmi:MI_Metadata"/>
  <xsl:variable name="identification" select="$record/gmd:identificationInfo[1]/*"/>
  <xsl:variable name="citation" select="$identification/gmd:citation/gmd:CI_Citation"/>
  <xsl:variable name="distribution" select="$record/gmd:distributionInfo/gmd:MD_Distribution"/>
  <xsl:variable name="constraints" select="$identification/gmd:resourceConstraints/*"/>

  <!-- Bounding boxes, skipping any that describe an area the resource excludes. -->
  <xsl:variable name="boxes"
    select="$identification//gmd:EX_GeographicBoundingBox[not(gmd:extentTypeCode/gco:Boolean = 'false' or
                                                               gmd:extentTypeCode/gco:Boolean = '0')]"/>

  <!-- The union of the bounding boxes. -->
  <xsl:variable name="west">
    <xsl:for-each select="$boxes/gmd:westBoundLongitude/*[string(number(.)) != 'NaN']">
      <xsl:sort select="." data-type="number" order="ascending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="number(.)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="east">
    <xsl:for-each select="$boxes/gmd:eastBoundLongitude/*[string(number(.)) != 'NaN']">
      <xsl:sort select="." data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="number(.)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="north">
    <xsl:for-each select="$boxes/gmd:northBoundLatitude/*[string(number(.)) != 'NaN']">
      <xsl:sort select="." data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="number(.)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="south">
    <xsl:for-each select="$boxes/gmd:southBoundLatitude/*[string(number(.)) != 'NaN']">
      <xsl:sort select="." data-type="number" order="ascending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="number(.)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="hasBoundingBox"
    select="string($west) != '' and string($east) != '' and
            string($north) != '' and string($south) != ''"/>

  <xsl:variable name="envelope"
    select="concat('ENVELOPE(', $west, ',', $east, ',', $north, ',', $south, ')')"/>

  <xsl:variable name="providerName">
    <xsl:choose>
      <xsl:when test="normalize-space($provider) != ''">
        <xsl:value-of select="normalize-space($provider)"/>
      </xsl:when>
      <xsl:when test="normalize-space($distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/*[1]) != ''">
        <xsl:value-of select="normalize-space($distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty/gmd:organisationName/*[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($record/gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName/*[1])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Keywords with GBL controlled vocabulary values. -->
  <xsl:variable name="resourceClassVocab">
    <xsl:text>|collections=Collections</xsl:text>
    <xsl:text>|datasets=Datasets</xsl:text>
    <xsl:text>|imagery=Imagery</xsl:text>
    <xsl:text>|maps=Maps</xsl:text>
    <xsl:text>|web services=Web services</xsl:text>
    <xsl:text>|websites=Websites</xsl:text>
    <xsl:text>|</xsl:text>
  </xsl:variable>

  <xsl:variable name="resourceTypeVocab">
    <xsl:text>|annotations=Annotations</xsl:text>
    <xsl:text>|basemaps=Basemaps</xsl:text>
    <xsl:text>|lidar=LiDAR</xsl:text>
    <xsl:text>|line data=Line data</xsl:text>
    <xsl:text>|mesh data=Mesh data</xsl:text>
    <xsl:text>|multi-spectral data=Multi-spectral data</xsl:text>
    <xsl:text>|oblique photographs=Oblique photographs</xsl:text>
    <xsl:text>|point cloud data=Point cloud data</xsl:text>
    <xsl:text>|point data=Point data</xsl:text>
    <xsl:text>|polygon data=Polygon data</xsl:text>
    <xsl:text>|raster data=Raster data</xsl:text>
    <xsl:text>|satellite imagery=Satellite imagery</xsl:text>
    <xsl:text>|streetview photographs=Streetview photographs</xsl:text>
    <xsl:text>|table data=Table data</xsl:text>
    <xsl:text>|aerial photographs=Aerial photographs</xsl:text>
    <xsl:text>|aerial views=Aerial views</xsl:text>
    <xsl:text>|aeronautical charts=Aeronautical charts</xsl:text>
    <xsl:text>|armillary spheres=Armillary spheres</xsl:text>
    <xsl:text>|astronautical charts=Astronautical charts</xsl:text>
    <xsl:text>|astronomical models=Astronomical models</xsl:text>
    <xsl:text>|atlases=Atlases</xsl:text>
    <xsl:text>|bathymetric maps=Bathymetric maps</xsl:text>
    <xsl:text>|block diagrams=Block diagrams</xsl:text>
    <xsl:text>|bottle-charts=Bottle-charts</xsl:text>
    <xsl:text>|cadastral maps=Cadastral maps</xsl:text>
    <xsl:text>|cartographic materials=Cartographic materials</xsl:text>
    <xsl:text>|cartographic materials for people with visual disabilities=Cartographic materials for people with visual disabilities</xsl:text>
    <xsl:text>|celestial charts=Celestial charts</xsl:text>
    <xsl:text>|celestial globes=Celestial globes</xsl:text>
    <xsl:text>|census data=Census data</xsl:text>
    <xsl:text>|children's atlases=Children's atlases</xsl:text>
    <xsl:text>|children's maps=Children's maps</xsl:text>
    <xsl:text>|comparative maps=Comparative maps</xsl:text>
    <xsl:text>|composite atlases=Composite atlases</xsl:text>
    <xsl:text>|digital elevation models=Digital elevation models</xsl:text>
    <xsl:text>|digital maps=Digital maps</xsl:text>
    <xsl:text>|early maps=Early maps</xsl:text>
    <xsl:text>|ephemerides=Ephemerides</xsl:text>
    <xsl:text>|ethnographic maps=Ethnographic maps</xsl:text>
    <xsl:text>|fire insurance maps=Fire insurance maps</xsl:text>
    <xsl:text>|flow maps=Flow maps</xsl:text>
    <xsl:text>|gazetteers=Gazetteers</xsl:text>
    <xsl:text>|geological cross-sections=Geological cross-sections</xsl:text>
    <xsl:text>|geological maps=Geological maps</xsl:text>
    <xsl:text>|globes=Globes</xsl:text>
    <xsl:text>|gores (maps)=Gores (Maps)</xsl:text>
    <xsl:text>|gravity anomaly maps=Gravity anomaly maps</xsl:text>
    <xsl:text>|index maps=Index maps</xsl:text>
    <xsl:text>|linguistic atlases=Linguistic atlases</xsl:text>
    <xsl:text>|loran charts=Loran charts</xsl:text>
    <xsl:text>|manuscript maps=Manuscript maps</xsl:text>
    <xsl:text>|mappae mundi=Mappae mundi</xsl:text>
    <xsl:text>|mental maps=Mental maps</xsl:text>
    <xsl:text>|meteorological charts=Meteorological charts</xsl:text>
    <xsl:text>|military maps=Military maps</xsl:text>
    <xsl:text>|mine maps=Mine maps</xsl:text>
    <xsl:text>|miniature maps=Miniature maps</xsl:text>
    <xsl:text>|nautical charts=Nautical charts</xsl:text>
    <xsl:text>|outline maps=Outline maps</xsl:text>
    <xsl:text>|photogrammetric maps=Photogrammetric maps</xsl:text>
    <xsl:text>|photomaps=Photomaps</xsl:text>
    <xsl:text>|physical maps=Physical maps</xsl:text>
    <xsl:text>|pictorial maps=Pictorial maps</xsl:text>
    <xsl:text>|plotting charts=Plotting charts</xsl:text>
    <xsl:text>|portolan charts=Portolan charts</xsl:text>
    <xsl:text>|quadrangle maps=Quadrangle maps</xsl:text>
    <xsl:text>|relief models=Relief models</xsl:text>
    <xsl:text>|remote-sensing maps=Remote-sensing maps</xsl:text>
    <xsl:text>|road maps=Road maps</xsl:text>
    <xsl:text>|statistical maps=Statistical maps</xsl:text>
    <xsl:text>|stick charts=Stick charts</xsl:text>
    <xsl:text>|strip maps=Strip maps</xsl:text>
    <xsl:text>|thematic maps=Thematic maps</xsl:text>
    <xsl:text>|topographic maps=Topographic maps</xsl:text>
    <xsl:text>|tourist maps=Tourist maps</xsl:text>
    <xsl:text>|upside-down maps=Upside-down maps</xsl:text>
    <xsl:text>|wall maps=Wall maps</xsl:text>
    <xsl:text>|world atlases=World atlases</xsl:text>
    <xsl:text>|world maps=World maps</xsl:text>
    <xsl:text>|worm's-eye views=Worm's-eye views</xsl:text>
    <xsl:text>|zoning maps=Zoning maps</xsl:text>
    <xsl:text>|</xsl:text>
  </xsl:variable>

  <!-- ISO topic categories and their spelled-out names, plus the Aardvark theme names. -->
  <xsl:variable name="themeVocab">
    <xsl:text>|farming=Agriculture</xsl:text>
    <xsl:text>|agriculture=Agriculture</xsl:text>
    <xsl:text>|biota=Biology</xsl:text>
    <xsl:text>|biology=Biology</xsl:text>
    <xsl:text>|biology and ecology=Biology</xsl:text>
    <xsl:text>|boundaries=Boundaries</xsl:text>
    <xsl:text>|climatologymeteorologyatmosphere=Climate</xsl:text>
    <xsl:text>|climatology, meteorology and atmosphere=Climate</xsl:text>
    <xsl:text>|climate=Climate</xsl:text>
    <xsl:text>|disaster=Events</xsl:text>
    <xsl:text>|economy=Economy</xsl:text>
    <xsl:text>|elevation=Elevation</xsl:text>
    <xsl:text>|environment=Environment</xsl:text>
    <xsl:text>|events=Events</xsl:text>
    <xsl:text>|geoscientificinformation=Geology</xsl:text>
    <xsl:text>|geoscientific information=Geology</xsl:text>
    <xsl:text>|geology=Geology</xsl:text>
    <xsl:text>|health=Health</xsl:text>
    <xsl:text>|imagerybasemapsearthcover=Imagery</xsl:text>
    <xsl:text>|imagery and base maps=Imagery</xsl:text>
    <xsl:text>|imagery=Imagery</xsl:text>
    <xsl:text>|inlandwaters=Inland Waters</xsl:text>
    <xsl:text>|inland waters=Inland Waters</xsl:text>
    <xsl:text>|land cover=Land Cover</xsl:text>
    <xsl:text>|location=Location</xsl:text>
    <xsl:text>|intelligencemilitary=Military</xsl:text>
    <xsl:text>|military=Military</xsl:text>
    <xsl:text>|oceans=Oceans</xsl:text>
    <xsl:text>|planningcadastre=Property</xsl:text>
    <xsl:text>|planning and cadastral=Property</xsl:text>
    <xsl:text>|property=Property</xsl:text>
    <xsl:text>|society=Society</xsl:text>
    <xsl:text>|structure=Structure</xsl:text>
    <xsl:text>|transportation=Transportation</xsl:text>
    <xsl:text>|utilitiescommunication=Utilities</xsl:text>
    <xsl:text>|utilities and communication=Utilities</xsl:text>
    <xsl:text>|utilities=Utilities</xsl:text>
    <xsl:text>|</xsl:text>
  </xsl:variable>

  <!--
    Keywords. Keyword sets from the GBL controlled thesauri are used as-is.
    Otherwise theme and discipline keywords become subjects, place keywords
    spatial coverage and temporal keywords temporal coverage. Everything else,
    including keywords with no type, goes in dcat_keyword_sm.
  -->
  <xsl:variable name="keywordSets" select="$identification/gmd:descriptiveKeywords/gmd:MD_Keywords"/>

  <xsl:variable name="controlledKeywordSets"
    select="$keywordSets[normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'GBL Resource Class' or
                         normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'GBL Resource Type' or
                         normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'ISO GBL Theme']"/>

  <xsl:variable name="resourceClassKeywords"
    select="$keywordSets[normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'GBL Resource Class']/gmd:keyword/*[1]"/>
  <xsl:variable name="resourceTypeKeywords"
    select="$keywordSets[normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'GBL Resource Type']/gmd:keyword/*[1]"/>
  <xsl:variable name="themeKeywords"
    select="$keywordSets[normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1]) = 'ISO GBL Theme']/gmd:keyword/*[1]"/>

  <xsl:variable name="freeKeywordSets"
    select="$keywordSets[count(. | $controlledKeywordSets) != count($controlledKeywordSets)]"/>

  <xsl:variable name="subjectKeywords"
    select="$freeKeywordSets[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'theme' or
                             gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'discipline']/gmd:keyword/*[1]"/>
  <xsl:variable name="placeKeywords"
    select="$freeKeywordSets[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'place']/gmd:keyword/*[1]"/>
  <xsl:variable name="temporalKeywords"
    select="$freeKeywordSets[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'temporal']/gmd:keyword/*[1]"/>
  <xsl:variable name="otherKeywords"
    select="$freeKeywordSets[not(gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'theme' or
                                 gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'discipline' or
                                 gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'place' or
                                 gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'temporal')]/gmd:keyword/*[1]"/>

  <xsl:variable name="explicitResourceClasses">
    <xsl:call-template name="value-list">
      <xsl:with-param name="nodes" select="$resourceClassKeywords"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="explicitResourceTypes">
    <xsl:call-template name="value-list">
      <xsl:with-param name="nodes" select="$resourceTypeKeywords"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="matchedResourceClasses">
    <xsl:for-each select="$subjectKeywords">
      <xsl:variable name="match">
        <xsl:call-template name="vocab-value">
          <xsl:with-param name="vocab" select="$resourceClassVocab"/>
          <xsl:with-param name="value" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="string($match) != ''">
        <xsl:value-of select="concat('&#10;', $match)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="matchedResourceTypes">
    <xsl:for-each select="$subjectKeywords">
      <xsl:variable name="match">
        <xsl:call-template name="vocab-value">
          <xsl:with-param name="vocab" select="$resourceTypeVocab"/>
          <xsl:with-param name="value" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="string($match) != ''">
        <xsl:value-of select="concat('&#10;', $match)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="matchedThemes">
    <xsl:for-each select="$subjectKeywords">
      <xsl:variable name="match">
        <xsl:call-template name="vocab-value">
          <xsl:with-param name="vocab" select="$themeVocab"/>
          <xsl:with-param name="value" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="string($match) != ''">
        <xsl:value-of select="concat('&#10;', $match)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="subjectValues">
    <xsl:for-each select="$subjectKeywords">
      <xsl:if test="normalize-space(.)">
        <xsl:variable name="asResourceClass">
          <xsl:call-template name="vocab-value">
            <xsl:with-param name="vocab" select="$resourceClassVocab"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="asResourceType">
          <xsl:call-template name="vocab-value">
            <xsl:with-param name="vocab" select="$resourceTypeVocab"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="asTheme">
          <xsl:call-template name="vocab-value">
            <xsl:with-param name="vocab" select="$themeVocab"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($asResourceClass) = '' and string($asResourceType) = '' and
                      string($asTheme) = ''">
          <xsl:value-of select="concat('&#10;', normalize-space(.))"/>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="themeValues">
    <xsl:for-each select="$themeKeywords | $identification/gmd:topicCategory/gmd:MD_TopicCategoryCode">
      <xsl:if test="normalize-space(.)">
        <xsl:variable name="match">
          <xsl:call-template name="vocab-value">
            <xsl:with-param name="vocab" select="$themeVocab"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string($match) != ''">
            <xsl:value-of select="concat('&#10;', $match)"/>
          </xsl:when>
          <!-- Theme is a controlled field, so only keep unknown values from the GBL thesaurus. -->
          <xsl:when test="not(self::gmd:MD_TopicCategoryCode)">
            <xsl:value-of select="concat('&#10;', normalize-space(.))"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="$matchedThemes"/>
  </xsl:variable>

  <!-- Scope of the record. ISO defaults to dataset when hierarchyLevel is absent. -->
  <xsl:variable name="scope"
    select="normalize-space($record/gmd:hierarchyLevel[1]/gmd:MD_ScopeCode/@codeListValue)"/>
  <xsl:variable name="presentationForms"
    select="$citation/gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue"/>

  <!--
    Vector geometry types. "composite" is left out: real records use it for
    both line and polygon layers, so it doesn't say which.
  -->
  <xsl:variable name="geometryTypes">
    <xsl:for-each select="$record/gmd:spatialRepresentationInfo/gmd:MD_VectorSpatialRepresentation/gmd:geometricObjects/gmd:MD_GeometricObjects/gmd:geometricObjectType/gmd:MD_GeometricObjectTypeCode">
      <xsl:variable name="code" select="translate(normalize-space(@codeListValue), $upper, $lower)"/>
      <xsl:choose>
        <xsl:when test="$code = 'point'">
          <xsl:text>&#10;Point data</xsl:text>
        </xsl:when>
        <xsl:when test="$code = 'curve'">
          <xsl:text>&#10;Line data</xsl:text>
        </xsl:when>
        <xsl:when test="$code = 'surface' or $code = 'complex'">
          <xsl:text>&#10;Polygon data</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="isRaster"
    select="$identification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue = 'grid' or
            $record/gmd:spatialRepresentationInfo/gmd:MD_GridSpatialRepresentation or
            $record/gmd:spatialRepresentationInfo/gmd:MD_Georectified or
            $record/gmd:spatialRepresentationInfo/gmd:MD_Georeferenceable or
            $record/gmd:spatialRepresentationInfo/gmi:MI_Georectified or
            $record/gmd:spatialRepresentationInfo/gmi:MI_Georeferenceable or
            $record/gmd:spatialRepresentationInfo//gmd:MD_GeometricObjectTypeCode[translate(@codeListValue, $upper, $lower) = 'raster']"/>

  <xsl:variable name="formatName"
    select="normalize-space(($distribution/gmd:distributionFormat/gmd:MD_Format/gmd:name/*[1] |
                             $distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorFormat/gmd:MD_Format/gmd:name/*[1])[1])"/>
  <xsl:variable name="formatKey" select="translate($formatName, $upper, $lower)"/>

  <!--
    Online resources. OGC and Esri services are recognized by protocol or URL,
    the remaining links are downloads when they say so and landing pages otherwise.
  -->
  <xsl:variable name="onlineResources"
    select="($distribution/gmd:transferOptions | $distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions)/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[normalize-space(gmd:linkage/gmd:URL) != '']"/>

  <xsl:variable name="wmtsResources"
    select="$onlineResources[contains(translate(gmd:protocol, $upper, $lower), 'ogc:wmts') or
                             contains(translate(gmd:linkage/gmd:URL, $upper, $lower), 'service=wmts')]"/>
  <xsl:variable name="wmsResources"
    select="$onlineResources[contains(translate(gmd:protocol, $upper, $lower), 'ogc:wms') or
                             contains(translate(gmd:linkage/gmd:URL, $upper, $lower), 'service=wms')]"/>
  <xsl:variable name="wfsResources"
    select="$onlineResources[contains(translate(gmd:protocol, $upper, $lower), 'ogc:wfs') or
                             contains(translate(gmd:linkage/gmd:URL, $upper, $lower), 'service=wfs')]"/>
  <xsl:variable name="wcsResources"
    select="$onlineResources[contains(translate(gmd:protocol, $upper, $lower), 'ogc:wcs') or
                             contains(translate(gmd:linkage/gmd:URL, $upper, $lower), 'service=wcs')]"/>
  <xsl:variable name="esriResources"
    select="$onlineResources[contains(translate(gmd:linkage/gmd:URL, $upper, $lower), '/rest/services/')]"/>
  <xsl:variable name="featureLayerResources"
    select="$esriResources[contains(translate(gmd:linkage/gmd:URL, $upper, $lower), '/featureserver')]"/>
  <xsl:variable name="imageLayerResources"
    select="$esriResources[contains(translate(gmd:linkage/gmd:URL, $upper, $lower), '/imageserver')]"/>
  <xsl:variable name="mapLayerResources"
    select="$esriResources[contains(translate(gmd:linkage/gmd:URL, $upper, $lower), '/mapserver')]"/>

  <xsl:variable name="serviceResources"
    select="$wmtsResources | $wmsResources | $wfsResources | $wcsResources | $esriResources"/>
  <xsl:variable name="downloadResources"
    select="$onlineResources[count(. | $serviceResources) != count($serviceResources)]
                            [gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue = 'download' or
                             contains(translate(gmd:protocol, $upper, $lower), 'download')]"/>
  <xsl:variable name="linkResources"
    select="$onlineResources[count(. | $serviceResources) != count($serviceResources)]
                            [count(. | $downloadResources) != count($downloadResources)]"/>

  <xsl:variable name="landingPage">
    <xsl:choose>
      <xsl:when test="starts-with(normalize-space($record/gmd:dataSetURI/*[1]), 'http')">
        <xsl:value-of select="normalize-space($record/gmd:dataSetURI/*[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($linkResources[1]/gmd:linkage/gmd:URL)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ==================================================================
       Record
       ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates select="gmd:MD_Metadata | gmi:MI_Metadata"/>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata | gmi:MI_Metadata">
    <xsl:text>{</xsl:text>

    <!-- Title (Required) -->
    <xsl:text>"dct_title_s": </xsl:text>
    <xsl:call-template name="json-string">
      <xsl:with-param name="text" select="$citation/gmd:title/*[1]"/>
    </xsl:call-template>
    <xsl:text>,</xsl:text>

    <!-- Alternative Title -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_alternative_sm'"/>
      <xsl:with-param name="nodes" select="$citation/gmd:alternateTitle/*[1]"/>
    </xsl:call-template>

    <!-- Description -->
    <xsl:variable name="descriptions">
      <xsl:if test="normalize-space($identification/gmd:abstract/*[1])">
        <xsl:text>,"Abstract: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space($identification/gmd:abstract/*[1])"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space($identification/gmd:purpose/*[1])">
        <xsl:text>,"Purpose: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space($identification/gmd:purpose/*[1])"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:if test="normalize-space($identification/gmd:supplementalInformation/*[1])">
        <xsl:text>,"Supplemental information: </xsl:text>
        <xsl:call-template name="escape-json">
          <xsl:with-param name="text" select="normalize-space($identification/gmd:supplementalInformation/*[1])"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'dct_description_sm'"/>
      <xsl:with-param name="items" select="$descriptions"/>
    </xsl:call-template>

    <!-- Language. ISO 639-2 codes, from the code list value when there is one. -->
    <xsl:variable name="languages">
      <xsl:for-each select="$identification/gmd:language">
        <xsl:variable name="code">
          <xsl:choose>
            <xsl:when test="normalize-space(gmd:LanguageCode/@codeListValue)">
              <xsl:value-of select="normalize-space(gmd:LanguageCode/@codeListValue)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- CharacterString languages may carry a country, as in "eng; USA" -->
        <xsl:variable name="language">
          <xsl:choose>
            <xsl:when test="contains($code, ';')">
              <xsl:value-of select="normalize-space(substring-before($code, ';'))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$code"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="string($language) != ''">
          <xsl:value-of select="concat('&#10;', translate($language, $upper, $lower))"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_language_sm'"/>
      <xsl:with-param name="values" select="$languages"/>
    </xsl:call-template>

    <!-- Creator -->
    <xsl:variable name="creators">
      <xsl:for-each select="$citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'originator' or
                                                                                    gmd:role/gmd:CI_RoleCode/@codeListValue = 'author']">
        <xsl:call-template name="party-name">
          <xsl:with-param name="party" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_creator_sm'"/>
      <xsl:with-param name="values" select="$creators"/>
    </xsl:call-template>

    <!-- Publisher -->
    <xsl:variable name="publishers">
      <xsl:for-each select="$citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher']">
        <xsl:call-template name="party-name">
          <xsl:with-param name="party" select="."/>
          <xsl:with-param name="prefer" select="'organisation'"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_publisher_sm'"/>
      <xsl:with-param name="values" select="$publishers"/>
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
      <xsl:value-of select="$explicitResourceClasses"/>
      <xsl:value-of select="$matchedResourceClasses"/>
      <xsl:if test="string($explicitResourceClasses) = ''">
        <xsl:choose>
          <xsl:when test="$scope = 'service' or $identification/self::srv:SV_ServiceIdentification">
            <xsl:text>&#10;Web services</xsl:text>
          </xsl:when>
          <xsl:when test="$scope = 'series'">
            <xsl:text>&#10;Collections</xsl:text>
          </xsl:when>
          <xsl:when test="$presentationForms = 'imageDigital' or $presentationForms = 'imageHardcopy'">
            <xsl:text>&#10;Imagery</xsl:text>
          </xsl:when>
          <xsl:when test="$presentationForms = 'mapHardcopy'">
            <xsl:text>&#10;Maps</xsl:text>
          </xsl:when>
          <xsl:when test="$scope = '' or $scope = 'dataset' or $scope = 'nonGeographicDataset' or
                          $scope = 'feature' or $scope = 'featureType' or $scope = 'tile'">
            <xsl:text>&#10;Datasets</xsl:text>
          </xsl:when>
          <xsl:when test="string($matchedResourceClasses) = ''">
            <xsl:text>&#10;Other</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'gbl_resourceClass_sm'"/>
      <xsl:with-param name="values" select="$resourceClasses"/>
    </xsl:call-template>

    <!-- Resource Type -->
    <xsl:variable name="resourceTypes">
      <xsl:value-of select="$explicitResourceTypes"/>
      <xsl:value-of select="$matchedResourceTypes"/>
      <xsl:if test="string($explicitResourceTypes) = ''">
        <xsl:choose>
          <xsl:when test="string($geometryTypes) != ''">
            <xsl:value-of select="$geometryTypes"/>
          </xsl:when>
          <xsl:when test="$isRaster">
            <xsl:text>&#10;Raster data</xsl:text>
          </xsl:when>
          <xsl:when test="$identification/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue = 'textTable'">
            <xsl:text>&#10;Table data</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'gbl_resourceType_sm'"/>
      <xsl:with-param name="values" select="$resourceTypes"/>
    </xsl:call-template>

    <!-- Subject -->
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_subject_sm'"/>
      <xsl:with-param name="values" select="$subjectValues"/>
    </xsl:call-template>

    <!-- Theme -->
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dcat_theme_sm'"/>
      <xsl:with-param name="values" select="$themeValues"/>
    </xsl:call-template>

    <!-- Keyword -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dcat_keyword_sm'"/>
      <xsl:with-param name="nodes" select="$otherKeywords"/>
    </xsl:call-template>

    <!--
      Temporal Coverage. Single dates keep whatever precision the source records;
      periods are rendered YYYY-YYYY, or YYYY-present for an open-ended period.
    -->
    <xsl:variable name="periods"
      select="$identification//gmd:temporalElement//*[local-name() = 'TimePeriod']"/>
    <xsl:variable name="instants"
      select="$identification//gmd:temporalElement//*[local-name() = 'TimeInstant'][not(ancestor::*[local-name() = 'TimePeriod'])]/*[local-name() = 'timePosition']"/>

    <xsl:variable name="temporals">
      <xsl:for-each select="$periods">
        <xsl:variable name="begin">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="(*[local-name() = 'beginPosition'] | *[local-name() = 'begin']//*[local-name() = 'timePosition'])[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="endPosition" select="(*[local-name() = 'endPosition'] | *[local-name() = 'end']//*[local-name() = 'timePosition'])[1]"/>
        <xsl:variable name="end">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="$endPosition"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($begin) != ''">
          <xsl:text>&#10;</xsl:text>
          <xsl:value-of select="$begin"/>
          <xsl:choose>
            <xsl:when test="string($end) != '' and string($end) != string($begin)">
              <xsl:value-of select="concat('-', $end)"/>
            </xsl:when>
            <xsl:when test="string($end) = '' and $endPosition/@indeterminatePosition = 'now'">
              <xsl:text>-present</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$instants">
        <xsl:if test="normalize-space(.)">
          <xsl:text>&#10;</xsl:text>
          <xsl:call-template name="format-date">
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:call-template name="value-list">
        <xsl:with-param name="nodes" select="$temporalKeywords"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_temporal_sm'"/>
      <xsl:with-param name="values" select="$temporals"/>
    </xsl:call-template>

    <!-- Date Issued -->
    <xsl:variable name="issued">
      <xsl:call-template name="format-date">
        <xsl:with-param name="value" select="$citation/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue = 'publication']/gmd:date/*[1]"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($issued) != ''">
      <xsl:text>"dct_issued_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($issued)"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!--
      Index Year. Every year of each time period, and the year of each instant.
      Falls back to temporal keywords that are years.
    -->
    <xsl:variable name="contentYears">
      <xsl:for-each select="$periods">
        <xsl:variable name="begin">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="(*[local-name() = 'beginPosition'] | *[local-name() = 'begin']//*[local-name() = 'timePosition'])[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="end">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="(*[local-name() = 'endPosition'] | *[local-name() = 'end']//*[local-name() = 'timePosition'])[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string($begin) != '' and string($end) != ''">
            <xsl:call-template name="year-range">
              <xsl:with-param name="from" select="number($begin)"/>
              <xsl:with-param name="to" select="number($end)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="string($begin) != ''">
            <xsl:value-of select="concat('&#10;', number($begin))"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
      <xsl:for-each select="$instants">
        <xsl:variable name="year">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($year) != ''">
          <xsl:value-of select="concat('&#10;', number($year))"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="indexYears">
      <xsl:choose>
        <xsl:when test="string($contentYears) != ''">
          <xsl:value-of select="$contentYears"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$temporalKeywords">
            <xsl:if test="translate(normalize-space(.), $digits, $nines) = '9999'">
              <xsl:value-of select="concat('&#10;', number(normalize-space(.)))"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="uniqueIndexYears">
      <xsl:call-template name="dedupe-values">
        <xsl:with-param name="values" select="$indexYears"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- Integers, so the newline-delimited list only needs its delimiters swapped. -->
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'gbl_indexYear_im'"/>
      <xsl:with-param name="items" select="translate($uniqueIndexYears, '&#10;', ',')"/>
    </xsl:call-template>

    <!-- Date Range. A Solr date range string. -->
    <xsl:variable name="dateRanges">
      <xsl:for-each select="$periods">
        <xsl:variable name="begin">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="(*[local-name() = 'beginPosition'] | *[local-name() = 'begin']//*[local-name() = 'timePosition'])[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="end">
          <xsl:call-template name="year">
            <xsl:with-param name="value" select="(*[local-name() = 'endPosition'] | *[local-name() = 'end']//*[local-name() = 'timePosition'])[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($begin) != '' and string($end) != ''">
          <xsl:value-of select="concat('&#10;[', $begin, ' TO ', $end, ']')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'gbl_dateRange_drsim'"/>
      <xsl:with-param name="values" select="$dateRanges"/>
    </xsl:call-template>

    <!-- Spatial Coverage -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_spatial_sm'"/>
      <xsl:with-param name="nodes" select="$placeKeywords"/>
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

    <!-- Rights -->
    <xsl:variable name="rights">
      <xsl:for-each select="$constraints/gmd:useLimitation/*[1]">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,"Use limitation: </xsl:text>
          <xsl:call-template name="escape-json">
            <xsl:with-param name="text" select="normalize-space(.)"/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$constraints/gmd:otherConstraints/*[1]">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,"Other constraints: </xsl:text>
          <xsl:call-template name="escape-json">
            <xsl:with-param name="text" select="normalize-space(.)"/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="$identification/gmd:credit/*[1]">
        <xsl:if test="normalize-space(.)">
          <xsl:text>,"Credit: </xsl:text>
          <xsl:call-template name="escape-json">
            <xsl:with-param name="text" select="normalize-space(.)"/>
          </xsl:call-template>
          <xsl:text>"</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-array">
      <xsl:with-param name="key" select="'dct_rights_sm'"/>
      <xsl:with-param name="items" select="$rights"/>
    </xsl:call-template>

    <!-- License. Creative Commons and Open Data Commons URIs, linked or written out. -->
    <xsl:variable name="licenses">
      <xsl:for-each select="$constraints/gmd:useLimitation/* | $constraints/gmd:otherConstraints/*">
        <xsl:variable name="text" select="normalize-space(concat(@xlink:href, ' ', .))"/>
        <xsl:call-template name="license-uri">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="domain" select="'creativecommons.org/'"/>
        </xsl:call-template>
        <xsl:call-template name="license-uri">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="domain" select="'opendatacommons.org/'"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_license_sm'"/>
      <xsl:with-param name="values" select="$licenses"/>
    </xsl:call-template>

    <!--
      Access Rights (Required). Restricted when an access constraint or security
      classification says so, otherwise Public. An access constraint of
      "license" means access needs one; "licenceUnrestricted" doesn't.
    -->
    <xsl:variable name="accessCodes"
      select="$constraints/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue"/>
    <xsl:variable name="otherConstraints"
      select="translate(normalize-space($constraints[gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue = 'otherRestrictions']/gmd:otherConstraints), $upper, $lower)"/>
    <xsl:variable name="classifications"
      select="$constraints/gmd:classification/gmd:MD_ClassificationCode/@codeListValue"/>
    <xsl:text>"dct_accessRights_s": "</xsl:text>
    <xsl:choose>
      <xsl:when test="$accessCodes = 'restricted' or $accessCodes = 'license' or $accessCodes = 'private' or
                      $accessCodes = 'confidential' or $accessCodes = 'sensitiveButUnclassified' or
                      $accessCodes = 'in-confidence'">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="contains($otherConstraints, 'restricted') and
                      not(contains($otherConstraints, 'unrestricted'))">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:when test="$classifications = 'restricted' or $classifications = 'confidential' or
                      $classifications = 'secret' or $classifications = 'topSecret' or
                      $classifications = 'sensitiveButUnclassified' or
                      $classifications = 'forOfficialUseOnly' or $classifications = 'protected' or
                      $classifications = 'limitedDistribution'">
        <xsl:text>Restricted</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Public</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>",</xsl:text>

    <!-- Format. Known formats use the Aardvark format values; others pass through. -->
    <xsl:variable name="format">
      <xsl:choose>
        <xsl:when test="contains($formatKey, 'geotiff')">GeoTIFF</xsl:when>
        <xsl:when test="contains($formatKey, 'jpeg2000') or contains($formatKey, 'jpeg 2000') or contains($formatKey, 'jp2')">JPEG2000</xsl:when>
        <xsl:when test="contains($formatKey, 'geojson')">GeoJSON</xsl:when>
        <xsl:when test="contains($formatKey, 'geopackage') or $formatKey = 'gpkg'">GeoPackage</xsl:when>
        <xsl:when test="contains($formatKey, 'geopdf')">GeoPDF</xsl:when>
        <xsl:when test="contains($formatKey, 'geodatabase')">Geodatabase</xsl:when>
        <xsl:when test="contains($formatKey, 'feature class')">Feature Class</xsl:when>
        <xsl:when test="contains($formatKey, 'shape')">Shapefile</xsl:when>
        <xsl:when test="contains($formatKey, 'kmz')">KMZ</xsl:when>
        <xsl:when test="contains($formatKey, 'kml')">KML</xsl:when>
        <xsl:when test="contains($formatKey, 'raster dataset')">Raster Dataset</xsl:when>
        <xsl:when test="contains($formatKey, 'tiff')">GeoTIFF</xsl:when>
        <xsl:when test="contains($formatKey, 'jpeg') or $formatKey = 'jpg'">JPEG</xsl:when>
        <xsl:when test="$formatKey = 'png'">PNG</xsl:when>
        <xsl:when test="$formatKey = 'pdf'">PDF</xsl:when>
        <xsl:when test="contains($formatKey, 'mrsid')">MrSID</xsl:when>
        <xsl:when test="$formatKey = 'las'">LAS</xsl:when>
        <xsl:when test="$formatKey = 'laz'">LAZ</xsl:when>
        <xsl:when test="contains($formatKey, 'arcgrid') or contains($formatKey, 'esri grid')">ArcGRID</xsl:when>
        <xsl:when test="contains($formatKey, 'dbase') or $formatKey = 'dbf' or $formatKey = 'csv'">Tabular Data</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$formatName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string($format) != ''">
      <xsl:text>"dct_format_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($format)"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- File Size. ISO transfer sizes are in megabytes. -->
    <xsl:variable name="transferSize"
      select="normalize-space(($distribution//gmd:MD_DigitalTransferOptions/gmd:transferSize/*[string(number(.)) != 'NaN'])[1])"/>
    <xsl:if test="$transferSize != ''">
      <xsl:text>"gbl_fileSize_s": "</xsl:text>
      <xsl:value-of select="concat($transferSize, ' MB')"/>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!-- WxS Identifier. OGC online resources carry the layer name in their name. -->
    <xsl:variable name="wxsIdentifier"
      select="normalize-space(($wmsResources/gmd:name/*[1] | $wfsResources/gmd:name/*[1] | $wcsResources/gmd:name/*[1])[1])"/>
    <xsl:if test="$wxsIdentifier != ''">
      <xsl:text>"gbl_wxsIdentifier_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="$wxsIdentifier"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- References. A serialized JSON object, so it's escaped a second time. -->
    <xsl:variable name="references">
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'http://schema.org/url'"/>
        <xsl:with-param name="url" select="$landingPage"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="count($downloadResources) = 1">
          <xsl:call-template name="reference">
            <xsl:with-param name="key" select="'http://schema.org/downloadUrl'"/>
            <xsl:with-param name="url" select="$downloadResources/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:when>
        <!-- More than one download is an array of labeled links. -->
        <xsl:when test="count($downloadResources) &gt; 1">
          <xsl:text>,"http://schema.org/downloadUrl":[</xsl:text>
          <xsl:for-each select="$downloadResources">
            <xsl:variable name="label">
              <xsl:choose>
                <xsl:when test="normalize-space(gmd:name/*[1])">
                  <xsl:value-of select="normalize-space(gmd:name/*[1])"/>
                </xsl:when>
                <xsl:when test="normalize-space(gmd:description/*[1])">
                  <xsl:value-of select="normalize-space(gmd:description/*[1])"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="value" select="normalize-space(gmd:linkage/gmd:URL)"/>
                    <xsl:with-param name="delimiter" select="'/'"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="position() != 1">
              <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>{"url":</xsl:text>
            <xsl:call-template name="json-string">
              <xsl:with-param name="text" select="gmd:linkage/gmd:URL"/>
            </xsl:call-template>
            <xsl:text>,"label":</xsl:text>
            <xsl:call-template name="json-string">
              <xsl:with-param name="text" select="string($label)"/>
            </xsl:call-template>
            <xsl:text>}</xsl:text>
          </xsl:for-each>
          <xsl:text>]</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wms'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$wmsResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wfs'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$wfsResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wcs'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$wcsResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wmts'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$wmtsResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#FeatureLayer'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$featureLayerResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#ImageMapLayer'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$imageLayerResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#DynamicMapLayer'"/>
        <xsl:with-param name="url">
          <xsl:call-template name="endpoint">
            <xsl:with-param name="url" select="$mapLayerResources[1]/gmd:linkage/gmd:URL"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($references) != ''">
      <xsl:text>"dct_references_s": "</xsl:text>
      <xsl:call-template name="escape-json">
        <xsl:with-param name="text" select="concat('{', substring(string($references), 2), '}')"/>
      </xsl:call-template>
      <xsl:text>",</xsl:text>
    </xsl:if>

    <!--
      ID (Required). The last segment of the record's identifier (so
      "edu.stanford.purl:bb338jh0716" gives "bb338jh0716"), prefixed with the
      provider. Falls back to the dataset URI, the citation identifier and the title.
    -->
    <xsl:variable name="identifiers"
      select="$record/gmd:fileIdentifier/*[1] |
              $citation/gmd:identifier/*/gmd:code/*[1] |
              $record/gmd:dataSetURI/*[1]"/>
    <xsl:variable name="localName">
      <xsl:for-each select="$identifiers[normalize-space(.) != '']">
        <xsl:if test="position() = 1">
          <xsl:variable name="path">
            <xsl:call-template name="substring-after-last">
              <xsl:with-param name="value" select="normalize-space(.)"/>
              <xsl:with-param name="delimiter" select="'/'"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="substring-after-last">
            <xsl:with-param name="value" select="string($path)"/>
            <xsl:with-param name="delimiter" select="':'"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="localSlug">
      <xsl:call-template name="slugify">
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="normalize-space($localName) != ''">
              <xsl:value-of select="string($localName)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$citation/gmd:title/*[1]"/>
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

    <!-- Identifier -->
    <xsl:call-template name="string-array">
      <xsl:with-param name="key" select="'dct_identifier_sm'"/>
      <xsl:with-param name="nodes" select="$identifiers"/>
    </xsl:call-template>

    <!--
      Modified. The metadata date stamp as a full UTC timestamp, which Solr
      requires; a date without a time is taken as midnight. A time zone offset
      is dropped rather than applied, since XSLT 1.0 has no date arithmetic.
    -->
    <xsl:variable name="stamp" select="normalize-space($record/gmd:dateStamp/*[1])"/>
    <xsl:variable name="stampDate">
      <xsl:call-template name="format-date">
        <xsl:with-param name="value" select="$stamp"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="stampTime" select="substring(substring-after($stamp, 'T'), 1, 8)"/>
    <xsl:variable name="datePattern" select="translate($stampDate, $digits, $nines)"/>
    <xsl:if test="$datePattern = '9999' or $datePattern = '9999-99' or $datePattern = '9999-99-99'">
      <xsl:text>"gbl_mdModified_dt": "</xsl:text>
      <xsl:value-of select="substring($stampDate, 1, 4)"/>
      <xsl:text>-</xsl:text>
      <xsl:choose>
        <xsl:when test="string-length($stampDate) &gt;= 7">
          <xsl:value-of select="substring($stampDate, 6, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>01</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>-</xsl:text>
      <xsl:choose>
        <xsl:when test="string-length($stampDate) = 10">
          <xsl:value-of select="substring($stampDate, 9, 2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>01</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>T</xsl:text>
      <xsl:choose>
        <xsl:when test="translate($stampTime, $digits, $nines) = '99:99:99'">
          <xsl:value-of select="$stampTime"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>00:00:00</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>Z",</xsl:text>
    </xsl:if>

    <!-- Metadata Version (Required) -->
    <xsl:text>"gbl_mdVersion_s": "Aardvark"</xsl:text>

    <xsl:text>}</xsl:text>
  </xsl:template>
</xsl:stylesheet>
