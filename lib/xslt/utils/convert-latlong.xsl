<!--

convert-latlong.xsl

Author: John Maurer (jmaurer@hawaii.edu)
Date: June 2007 (when I was at National Snow and Ice Data Center)

This Extensible Stylesheet Language for Transformations (XSLT) document
converts a latitude or longitude decimal value from positive and negative
numbers (e.g. 180, 89.2, -180, -89.2) to strings that indicate the
hemisphere (e.g. 180 E, 89.2 N, 180 W, 89.2 S). A zero value is returned
unchanged (e.g. 0). 

You can import this XSLT in other XSLT files to call the "convert-latlong" 
template for accomplishing this. Here is an example import statement:

<xsl:import href="convert-latlong.xsl"/>

For more information on XSLT see:

http://en.wikipedia.org/wiki/XSLT
http://www.w3.org/TR/xslt

-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="text"/>

  <!-- This template converts latitude and longitude values from positive
       and negative integers (e.g. 180, 90, -180, -90) to strings that
       indicate the hemisphere (e.g. 180 E, 90 N, 180 W, 90 S). A zero
       value is returned unchanged (e.g. 0): -->

  <xsl:template name="convert-latlong">
    <xsl:param name="latitude"/>
    <xsl:param name="longitude"/>
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="$latitude">
        <xsl:choose>
          <xsl:when test="number( $value ) &gt; 1">
            <xsl:value-of select="concat( $value, ' N' )"/>
          </xsl:when>
          <xsl:when test="number( $value ) &lt; 1">
            <xsl:value-of select="concat( substring-after( $value, '-' ), ' S' )"/>
          </xsl:when>
          <!-- If zero, just return the value: -->
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$longitude">
        <xsl:choose>
          <xsl:when test="number( $value ) &gt; 1">
            <xsl:value-of select="concat( $value, ' E' )"/>
          </xsl:when>
          <xsl:when test="number( $value ) &lt; 1">
            <xsl:value-of select="concat( substring-after( $value, '-' ), ' W' )"/>
          </xsl:when>
          <!-- If zero, just return the value: -->
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
