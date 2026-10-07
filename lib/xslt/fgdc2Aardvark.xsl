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

  <!--
    A link with any "<URL:...>" wrapper removed, or nothing when it isn't an
    http(s) URL. FGDC allows free text here, so paths and bare hostnames turn up.
  -->
  <xsl:template name="link-url">
    <xsl:param name="value"/>
    <xsl:variable name="text" select="normalize-space($value)"/>
    <xsl:variable name="unwrapped">
      <xsl:choose>
        <xsl:when test="starts-with($text, '&lt;') and substring($text, string-length($text)) = '&gt;'">
          <xsl:value-of select="normalize-space(substring($text, 2, string-length($text) - 2))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="starts-with(translate($unwrapped, $upper, $lower), 'url:')">
          <xsl:value-of select="normalize-space(substring($unwrapped, 5))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$unwrapped"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="scheme" select="translate(substring-before($url, '://'), $upper, $lower)"/>
    <xsl:if test="($scheme = 'http' or $scheme = 'https') and not(contains($url, ' ')) and
                  substring-after($url, '://') != ''">
      <xsl:value-of select="$url"/>
    </xsl:if>
  </xsl:template>

  <!-- The lowercased path of a URL, without its query string or fragment. -->
  <xsl:template name="url-path">
    <xsl:param name="url"/>
    <xsl:variable name="afterScheme" select="translate(substring-after($url, '://'), $upper, $lower)"/>
    <xsl:variable name="hostAndPath">
      <xsl:choose>
        <xsl:when test="contains($afterScheme, '?')">
          <xsl:value-of select="substring-before($afterScheme, '?')"/>
        </xsl:when>
        <xsl:when test="contains($afterScheme, '#')">
          <xsl:value-of select="substring-before($afterScheme, '#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$afterScheme"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="contains($hostAndPath, '/')">
      <xsl:value-of select="concat('/', substring-after($hostAndPath, '/'))"/>
    </xsl:if>
  </xsl:template>

  <!--
    What a link is, from its URL and the name of the format it's distributed in:
    an OGC or Esri service, FGDC or HTML metadata, a download or a web page.
    Nothing for a site's home page, which says nothing about the record.
  -->
  <xsl:template name="link-kind">
    <xsl:param name="url"/>
    <xsl:param name="format"/>
    <xsl:variable name="lowerUrl" select="translate($url, $upper, $lower)"/>
    <xsl:variable name="formatKey" select="translate($format, $upper, $lower)"/>
    <xsl:variable name="path">
      <xsl:call-template name="url-path">
        <xsl:with-param name="url" select="$url"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="segments" select="concat($path, '/')"/>
    <xsl:variable name="fileName">
      <xsl:call-template name="substring-after-last">
        <xsl:with-param name="value" select="$path"/>
        <xsl:with-param name="delimiter" select="'/'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="extension">
      <xsl:if test="contains($fileName, '.')">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="value" select="$fileName"/>
          <xsl:with-param name="delimiter" select="'.'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="extensionKey" select="concat('|', $extension, '|')"/>
    <xsl:choose>
      <xsl:when test="(string($path) = '' or string($path) = '/') and not(contains($url, '?'))"/>
      <xsl:when test="contains($lowerUrl, 'service=wmts') or contains($segments, '/wmts/') or
                      contains($formatKey, 'wmts')">wmts</xsl:when>
      <xsl:when test="contains($lowerUrl, 'service=wms') or contains($segments, '/wms/') or
                      contains($segments, '/wmsserver/') or contains($formatKey, 'wms')">wms</xsl:when>
      <xsl:when test="contains($lowerUrl, 'service=wfs') or contains($segments, '/wfs/') or
                      contains($segments, '/wfsserver/') or contains($formatKey, 'wfs')">wfs</xsl:when>
      <xsl:when test="contains($lowerUrl, 'service=wcs') or contains($segments, '/wcs/') or
                      contains($segments, '/wcsserver/') or contains($formatKey, 'wcs')">wcs</xsl:when>
      <xsl:when test="contains($path, '/rest/services/')">
        <xsl:choose>
          <xsl:when test="contains($path, '/featureserver')">featureLayer</xsl:when>
          <xsl:when test="contains($path, '/imageserver')">imageLayer</xsl:when>
          <xsl:when test="contains($path, '/mapserver')">mapLayer</xsl:when>
          <xsl:otherwise>service</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($formatKey, 'metadata') and
                      (contains($formatKey, 'html') or $extension = 'html' or $extension = 'htm')">html</xsl:when>
      <xsl:when test="contains($formatKey, 'metadata')">fgdc</xsl:when>
      <xsl:when test="contains($webPageExtensions, $extensionKey)">page</xsl:when>
      <xsl:when test="contains($fileExtensions, $extensionKey) or contains($path, '/download')">download</xsl:when>
      <xsl:otherwise>page</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    The links of one kind from $links, each as a newline, the URL, a tab and the
    format name. A URL is only listed once.
  -->
  <xsl:template name="links-of-kind">
    <xsl:param name="kind"/>
    <xsl:param name="links"/>
    <xsl:param name="seen" select="'&#10;'"/>
    <xsl:variable name="marker" select="concat('&#10;', $kind, '&#9;')"/>
    <xsl:if test="contains($links, $marker)">
      <xsl:variable name="line" select="substring-before(substring-after($links, $marker), '&#10;')"/>
      <xsl:variable name="url" select="substring-before($line, '&#9;')"/>
      <xsl:if test="not(contains($seen, concat('&#10;', $url, '&#10;')))">
        <xsl:value-of select="concat('&#10;', $line)"/>
      </xsl:if>
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="$kind"/>
        <xsl:with-param name="links"
          select="concat('&#10;', substring-after(substring-after($links, $marker), '&#10;'))"/>
        <xsl:with-param name="seen" select="concat($seen, $url, '&#10;')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- The URL of the first link of a kind. -->
  <xsl:template name="first-link-of-kind">
    <xsl:param name="kind"/>
    <xsl:variable name="links">
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="$kind"/>
        <xsl:with-param name="links" select="$onlineLinks"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="substring-before(substring-after($links, '&#10;'), '&#9;')"/>
  </xsl:template>

  <!-- A reference to the first link of a kind. -->
  <xsl:template name="link-reference">
    <xsl:param name="key"/>
    <xsl:param name="kind"/>
    <xsl:call-template name="reference">
      <xsl:with-param name="key" select="$key"/>
      <xsl:with-param name="url">
        <xsl:call-template name="first-link-of-kind">
          <xsl:with-param name="kind" select="$kind"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- A reference to the endpoint of the first service link of a kind. -->
  <xsl:template name="service-reference">
    <xsl:param name="key"/>
    <xsl:param name="kind"/>
    <xsl:variable name="url">
      <xsl:call-template name="first-link-of-kind">
        <xsl:with-param name="kind" select="$kind"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="reference">
      <xsl:with-param name="key" select="$key"/>
      <xsl:with-param name="url">
        <xsl:call-template name="endpoint">
          <xsl:with-param name="url" select="string($url)"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!--
    The members of a downloadUrl array for a links-of-kind list, each with a
    leading comma and labeled with its format name, or else its file name.
  -->
  <xsl:template name="download-items">
    <xsl:param name="links"/>
    <xsl:if test="contains($links, '&#10;')">
      <xsl:variable name="rest" select="substring-after($links, '&#10;')"/>
      <xsl:variable name="line">
        <xsl:choose>
          <xsl:when test="contains($rest, '&#10;')">
            <xsl:value-of select="substring-before($rest, '&#10;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$rest"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="url" select="substring-before($line, '&#9;')"/>
      <xsl:variable name="label">
        <xsl:choose>
          <xsl:when test="substring-after($line, '&#9;') != ''">
            <xsl:value-of select="substring-after($line, '&#9;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="substring-after-last">
              <xsl:with-param name="value" select="substring-before(concat($url, '?'), '?')"/>
              <xsl:with-param name="delimiter" select="'/'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>,{"url":</xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="$url"/>
      </xsl:call-template>
      <xsl:text>,"label":</xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($label)"/>
      </xsl:call-template>
      <xsl:text>}</xsl:text>
      <xsl:call-template name="download-items">
        <xsl:with-param name="links" select="$rest"/>
      </xsl:call-template>
    </xsl:if>
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

  <!-- The value of the first of a URL's query parameters that names an OGC layer. -->
  <xsl:template name="layer-parameter">
    <xsl:param name="url"/>
    <xsl:variable name="query" select="concat('&amp;', substring-after($url, '?'), '&amp;')"/>
    <xsl:variable name="lowerQuery" select="translate($query, $upper, $lower)"/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="contains($lowerQuery, '&amp;layers=')">layers</xsl:when>
        <xsl:when test="contains($lowerQuery, '&amp;typenames=')">typenames</xsl:when>
        <xsl:when test="contains($lowerQuery, '&amp;typename=')">typename</xsl:when>
        <xsl:when test="contains($lowerQuery, '&amp;coverageid=')">coverageid</xsl:when>
        <xsl:when test="contains($lowerQuery, '&amp;coverage=')">coverage</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string($name) != ''">
      <xsl:variable name="start"
        select="string-length(substring-before($lowerQuery, concat('&amp;', $name, '='))) +
                string-length($name) + 3"/>
      <xsl:variable name="value" select="substring-before(substring($query, $start), '&amp;')"/>
      <!-- Only the first of a comma-separated list of layers. -->
      <xsl:variable name="layer">
        <xsl:choose>
          <xsl:when test="contains($value, ',')">
            <xsl:value-of select="substring-before($value, ',')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="colon">
        <xsl:call-template name="replace-substring">
          <xsl:with-param name="value" select="string($layer)"/>
          <xsl:with-param name="from" select="'%3A'"/>
          <xsl:with-param name="to" select="':'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:call-template name="replace-substring">
        <xsl:with-param name="value" select="string($colon)"/>
        <xsl:with-param name="from" select="'%3a'"/>
        <xsl:with-param name="to" select="':'"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- The first layer name found in the URLs of a links-of-kind list. -->
  <xsl:template name="first-layer-name">
    <xsl:param name="links"/>
    <xsl:if test="contains($links, '&#10;')">
      <xsl:variable name="layer">
        <xsl:call-template name="layer-parameter">
          <xsl:with-param name="url"
            select="substring-before(substring-after($links, '&#10;'), '&#9;')"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="normalize-space($layer) != ''">
          <xsl:value-of select="normalize-space($layer)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="first-layer-name">
            <xsl:with-param name="links" select="substring-after($links, '&#10;')"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
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

  <xsl:variable name="resourceClassKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'GBL Resource Class']/themekey"/>
  <xsl:variable name="resourceTypeKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'GBL Resource Type']/themekey"/>
  <xsl:variable name="themeKeywords"
    select="/metadata/idinfo/keywords/theme[normalize-space(themekt) = 'ISO GBL Theme']/themekey"/>

  <xsl:variable name="freeKeywords"
    select="/metadata/idinfo/keywords/theme[not(normalize-space(themekt) = 'GBL Resource Class' or
                                                normalize-space(themekt) = 'GBL Resource Type' or
                                                normalize-space(themekt) = 'ISO GBL Theme')]/themekey"/>

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
    <xsl:for-each select="$freeKeywords">
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
    <xsl:for-each select="$freeKeywords">
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
    <xsl:for-each select="$freeKeywords">
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
    <xsl:for-each select="$freeKeywords">
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
    <xsl:for-each select="$themeKeywords">
      <xsl:if test="normalize-space(.)">
        <xsl:variable name="match">
          <xsl:call-template name="vocab-value">
            <xsl:with-param name="vocab" select="$themeVocab"/>
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:text>&#10;</xsl:text>
        <xsl:choose>
          <xsl:when test="string($match) != ''">
            <xsl:value-of select="$match"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
    <xsl:value-of select="$matchedThemes"/>
  </xsl:variable>

  <xsl:variable name="geoform"
    select="translate(normalize-space(/metadata/idinfo/citation/citeinfo/geoform), $upper, $lower)"/>
  <xsl:variable name="sdtsType"
    select="translate(normalize-space(/metadata/spdoinfo/ptvctinf/sdtsterm/sdtstype), $upper, $lower)"/>
  <xsl:variable name="directReference"
    select="translate(normalize-space(/metadata/spdoinfo/direct), $upper, $lower)"/>
  <xsl:variable name="formatName"
    select="translate(normalize-space(/metadata/distinfo/stdorder/digform/digtinfo/formname), $upper, $lower)"/>

  <!-- File extensions of links that are downloads, and of links that are web pages. -->
  <xsl:variable name="fileExtensions">
    <xsl:text>|zip|gz|tgz|tar|7z|rar|kmz|kml|shp|gpkg|gdb|mdb|geojson|topojson|gml|csv|xls|xlsx|dbf</xsl:text>
    <xsl:text>|tif|tiff|jp2|sid|ecw|img|dem|asc|e00|las|laz|nc|hdf|h5|pdf|jpg|jpeg|png|gif|dwg|dxf|</xsl:text>
  </xsl:variable>
  <xsl:variable name="webPageExtensions" select="'|htm|html|shtml|php|asp|aspx|jsp|cfm|cgi|'"/>

  <!--
    Online links in document order, each as a newline, its kind, a tab, the URL,
    a tab and the format name. The citation's online linkage comes first, then
    browse graphics, which are thumbnails when they're URLs rather than file
    names, then the network resources of each digital form it's distributed in.
  -->
  <xsl:variable name="onlineLinks">
    <xsl:for-each select="/metadata/idinfo/citation/citeinfo/onlink |
                          /metadata/idinfo/browse/browsen |
                          /metadata/distinfo/stdorder/digform/digtopt/onlinopt/computer/networka/networkr">
      <xsl:variable name="url">
        <xsl:call-template name="link-url">
          <xsl:with-param name="value" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="format" select="normalize-space(ancestor::digform[1]/digtinfo/formname)"/>
      <xsl:variable name="kind">
        <xsl:choose>
          <xsl:when test="string($url) = ''"/>
          <xsl:when test="self::browsen">thumbnail</xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="link-kind">
              <xsl:with-param name="url" select="string($url)"/>
              <xsl:with-param name="format" select="$format"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="string($kind) != ''">
        <xsl:value-of select="concat('&#10;', $kind, '&#9;', $url, '&#9;', $format)"/>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>

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
      <xsl:value-of select="$explicitResourceClasses"/>
      <xsl:value-of select="$matchedResourceClasses"/>
      <xsl:if test="string($explicitResourceClasses) = ''">
        <xsl:choose>
          <xsl:when test="contains($geoform, 'remote-sensing image')">
            <xsl:text>&#10;Imagery</xsl:text>
          </xsl:when>
          <xsl:when test="contains($geoform, 'digital data')">
            <xsl:text>&#10;Datasets</xsl:text>
          </xsl:when>
          <xsl:when test="contains($geoform, 'web service')">
            <xsl:text>&#10;Web services</xsl:text>
          </xsl:when>
          <xsl:when test="contains($geoform, 'website')">
            <xsl:text>&#10;Websites</xsl:text>
          </xsl:when>
          <xsl:when test="contains($geoform, 'collection')">
            <xsl:text>&#10;Collections</xsl:text>
          </xsl:when>
          <xsl:when test="contains($geoform, 'map') or contains($geoform, 'atlas')">
            <xsl:text>&#10;Maps</xsl:text>
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
          <xsl:when test="contains($sdtsType, 'polygon')">
            <xsl:text>&#10;Polygon data</xsl:text>
          </xsl:when>
          <xsl:when test="contains($sdtsType, 'point') or contains($sdtsType, 'node')">
            <xsl:text>&#10;Point data</xsl:text>
          </xsl:when>
          <xsl:when test="contains($sdtsType, 'string') or contains($sdtsType, 'chain') or
                          contains($sdtsType, 'arc') or contains($sdtsType, 'link') or
                          contains($sdtsType, 'line')">
            <xsl:text>&#10;Line data</xsl:text>
          </xsl:when>
          <xsl:when test="contains($directReference, 'raster')">
            <xsl:text>&#10;Raster data</xsl:text>
          </xsl:when>
          <xsl:when test="contains($directReference, 'point')">
            <xsl:text>&#10;Point data</xsl:text>
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

    <!--
      Temporal Coverage. Single dates keep whatever precision the source records;
      ranges are rendered YYYY-YYYY.
    -->
    <xsl:variable name="temporals">
      <xsl:for-each select="idinfo/timeperd/timeinfo/sngdate/caldate |
                            idinfo/timeperd/timeinfo/mdattim/sngdate/caldate">
        <xsl:if test="normalize-space(.)">
          <xsl:text>&#10;</xsl:text>
          <xsl:call-template name="format-date">
            <xsl:with-param name="value" select="."/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="idinfo/timeperd/timeinfo/rngdates">
        <xsl:if test="normalize-space(begdate)">
          <xsl:text>&#10;</xsl:text>
          <xsl:value-of select="substring(normalize-space(begdate), 1, 4)"/>
          <xsl:if test="substring(normalize-space(begdate), 1, 4) !=
                        substring(normalize-space(enddate), 1, 4) and normalize-space(enddate)">
            <xsl:text>-</xsl:text>
            <xsl:value-of select="substring(normalize-space(enddate), 1, 4)"/>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
      <xsl:call-template name="value-list">
        <xsl:with-param name="nodes" select="idinfo/keywords/temporal/tempkey"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="emit-values-array">
      <xsl:with-param name="key" select="'dct_temporal_sm'"/>
      <xsl:with-param name="values" select="$temporals"/>
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
          <xsl:value-of select="format-number(number(substring(normalize-space(idinfo/timeperd/timeinfo/sngdate/caldate), 1, 4)), '0')"/>
        </xsl:when>
        <xsl:when test="string(number(substring(normalize-space(idinfo/timeperd/timeinfo/mdattim/sngdate[1]/caldate), 1, 4))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="format-number(number(substring(normalize-space(idinfo/timeperd/timeinfo/mdattim/sngdate[1]/caldate), 1, 4)), '0')"/>
        </xsl:when>
        <xsl:when test="string(number(substring(normalize-space(idinfo/timeperd/timeinfo/rngdates/begdate), 1, 4))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="format-number(number(substring(normalize-space(idinfo/timeperd/timeinfo/rngdates/begdate), 1, 4)), '0')"/>
        </xsl:when>
        <xsl:when test="string(number(normalize-space(idinfo/keywords/temporal/tempkey[1]))) != 'NaN'">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="format-number(number(normalize-space(idinfo/keywords/temporal/tempkey[1])), '0')"/>
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

    <xsl:variable name="wmsLinks">
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="'wms'"/>
        <xsl:with-param name="links" select="$onlineLinks"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="wfsLinks">
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="'wfs'"/>
        <xsl:with-param name="links" select="$onlineLinks"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="wcsLinks">
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="'wcs'"/>
        <xsl:with-param name="links" select="$onlineLinks"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="downloadLinks">
      <xsl:call-template name="links-of-kind">
        <xsl:with-param name="kind" select="'download'"/>
        <xsl:with-param name="links" select="$onlineLinks"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="downloadCount"
      select="string-length($downloadLinks) - string-length(translate($downloadLinks, '&#10;', ''))"/>

    <!-- WxS Identifier. FGDC has no field for it, so it comes from the layer an OGC link asks for. -->
    <xsl:variable name="wxsIdentifier">
      <xsl:call-template name="first-layer-name">
        <xsl:with-param name="links" select="concat($wmsLinks, $wfsLinks, $wcsLinks)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($wxsIdentifier) != ''">
      <xsl:text>"gbl_wxsIdentifier_s": </xsl:text>
      <xsl:call-template name="json-string">
        <xsl:with-param name="text" select="string($wxsIdentifier)"/>
      </xsl:call-template>
      <xsl:text>,</xsl:text>
    </xsl:if>

    <!-- References. A serialized JSON object, so it's escaped a second time. -->
    <xsl:variable name="references">
      <xsl:call-template name="link-reference">
        <xsl:with-param name="key" select="'http://schema.org/url'"/>
        <xsl:with-param name="kind" select="'page'"/>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$downloadCount = 1">
          <xsl:call-template name="reference">
            <xsl:with-param name="key" select="'http://schema.org/downloadUrl'"/>
            <xsl:with-param name="url" select="substring-before(substring-after($downloadLinks, '&#10;'), '&#9;')"/>
          </xsl:call-template>
        </xsl:when>
        <!-- More than one download is an array of links labeled with their format. -->
        <xsl:when test="$downloadCount &gt; 1">
          <xsl:variable name="downloadItems">
            <xsl:call-template name="download-items">
              <xsl:with-param name="links" select="$downloadLinks"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:text>,"http://schema.org/downloadUrl":[</xsl:text>
          <xsl:value-of select="substring($downloadItems, 2)"/>
          <xsl:text>]</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="link-reference">
        <xsl:with-param name="key" select="'http://schema.org/thumbnailUrl'"/>
        <xsl:with-param name="kind" select="'thumbnail'"/>
      </xsl:call-template>
      <xsl:call-template name="link-reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/cat/csw/csdgm'"/>
        <xsl:with-param name="kind" select="'fgdc'"/>
      </xsl:call-template>
      <xsl:call-template name="link-reference">
        <xsl:with-param name="key" select="'http://www.w3.org/1999/xhtml'"/>
        <xsl:with-param name="kind" select="'html'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wms'"/>
        <xsl:with-param name="kind" select="'wms'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wfs'"/>
        <xsl:with-param name="kind" select="'wfs'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wcs'"/>
        <xsl:with-param name="kind" select="'wcs'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'http://www.opengis.net/def/serviceType/ogc/wmts'"/>
        <xsl:with-param name="kind" select="'wmts'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#FeatureLayer'"/>
        <xsl:with-param name="kind" select="'featureLayer'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#ImageMapLayer'"/>
        <xsl:with-param name="kind" select="'imageLayer'"/>
      </xsl:call-template>
      <xsl:call-template name="service-reference">
        <xsl:with-param name="key" select="'urn:x-esri:serviceType:ArcGIS#DynamicMapLayer'"/>
        <xsl:with-param name="kind" select="'mapLayer'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($references) != ''">
      <xsl:text>"dct_references_s": "</xsl:text>
      <xsl:call-template name="escape-json">
        <xsl:with-param name="text" select="concat('{', substring(string($references), 2), '}')"/>
      </xsl:call-template>
      <xsl:text>",</xsl:text>
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
