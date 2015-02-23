<!--

wrap-text.xsl

Author: John Maurer (jmaurer@hawaii.edu)
Date: June 2007 (when I was at National Snow and Ice Data Center)

This Extensible Stylesheet Language for Transformations (XSLT) document takes
an input string and outputs it with line wrapping. Lines get wrapped at the
specified $max-line-length of characters. You can import this XSLT in other 
XSLT files to call the "wrap-text" template for accomplishing this. Here is 
an example import statement:

<xsl:import href="wrap-text.xsl"/>

The "wrap-text" template uses the "fold" and "chop" helper templates to 
accomplish the end result. "wrap-text" first splits the file up into sections
before and after blank lines (2 consecutive newlines); each of these sections
gets passed to the "fold" template, which in turn calls the "chop" template
to chop up the string into $max-line-length character lines. "fold" indents 
each chopped line by the $indent string, which the user can define as the 
number of spaces that they want to precede every line.

For more information on XSLT see:

http://en.wikipedia.org/wiki/XSLT
http://www.w3.org/TR/xslt

-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="text"/>

  <!-- Define a variable for creating a newline/break: -->

  <xsl:variable name="newline">
<xsl:text>
</xsl:text>
  </xsl:variable>

  <!-- Define a variable for creating a blank line, which
       is two consecutive newlines characters: -->

  <xsl:variable name="blank-line" select="concat( $newline, $newline )"/>

  <!-- Define a variable for a single space character: -->

  <xsl:variable name="space" select="' '"/>

  <!-- A template to wrap text into lines of $max-line-length. 
       Each line will get one indent: -->

  <xsl:template name="wrap-text">
    <xsl:param name="original-string"/>
    <xsl:param name="max-line-length"/>
    <xsl:param name="indent"/>
    <xsl:choose>
      <xsl:when test="contains( $original-string, $blank-line )">
        <xsl:comment>Call "fold" on the string before the blank line to wrap this text:</xsl:comment>
        <xsl:call-template name="fold">
          <xsl:with-param name="original-string" select="substring-before( $original-string, $blank-line )"/>
          <xsl:with-param name="max-line-length" select="$max-line-length"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
        <xsl:value-of select="$newline"/>
        <xsl:comment>Call wrap-text recursively on remaining text after the blank line:</xsl:comment>
        <xsl:call-template name="wrap-text">
          <xsl:with-param name="original-string" select="substring-after( $original-string, $blank-line )"/>
          <xsl:with-param name="max-line-length" select="$max-line-length"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>If the text does not contain any blank lines, call "fold" to wrap the text:</xsl:comment>
        <xsl:call-template name="fold">
          <xsl:with-param name="original-string" select="$original-string"/>
          <xsl:with-param name="max-line-length" select="$max-line-length"/>
          <xsl:with-param name="indent" select="$indent"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="fold">
    <xsl:param name="original-string"/>
    <xsl:param name="max-line-length"/>
    <xsl:param name="indent"/>
    <xsl:variable name="print-string">
      <xsl:choose>
        <xsl:when test="string-length( $original-string ) &gt; number( $max-line-length )">
          <xsl:comment>Text is longer than max, chop it down and print next line:</xsl:comment>
          <xsl:call-template name="chop">
            <xsl:with-param name="newstring" select="''"/>
            <xsl:with-param name="original-string" select="$original-string"/>
            <xsl:with-param name="max-line-length" select="$max-line-length"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>Text is less than max length, so print the whole thing:</xsl:comment>
          <xsl:value-of select="$original-string"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$indent"/>
    <xsl:value-of select="$print-string"/>
    <xsl:value-of select="$newline"/>
    <xsl:comment>Check if there is any remaining text after the above chop:</xsl:comment>
    <xsl:variable name="remaining-string" select="substring-after( $original-string, $print-string )"/>
    <xsl:if test="string-length( $remaining-string )">
      <xsl:comment>Call "fold" recursively on the remaining text:</xsl:comment>
      <xsl:call-template name="fold">
        <xsl:with-param name="original-string" select="$remaining-string"/>
        <xsl:with-param name="max-line-length" select="$max-line-length"/>
        <xsl:with-param name="indent" select="$indent"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chop">
    <xsl:param name="newstring"/>
    <xsl:param name="original-string"/>
    <xsl:param name="max-line-length"/>
    <xsl:variable name="substring-before-space">
      <xsl:comment>This is the part of the string before the first occuring space character, if any:</xsl:comment>
      <xsl:choose>
        <xsl:when test="contains( $original-string, $space )">
          <xsl:comment>This text contains a space character; chop it off at the first space and add to newstring:</xsl:comment>
          <xsl:value-of select="concat( $newstring, substring-before( $original-string, $space ), $space )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>This text does not contain any space characters so use it all:</xsl:comment>
          <xsl:value-of select="concat( $newstring, $original-string )"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="substring-after-space">
      <xsl:comment>This is the part of the string after the first occuring space character, if any:</xsl:comment>
      <xsl:choose>
        <xsl:when test="contains( $original-string, $space )">
          <xsl:comment>This text contains a space character; take what is after the first space:</xsl:comment>
          <xsl:value-of select="substring-after( $original-string, $space )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>This text does not contain any space characters so define a null string here:</xsl:comment>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="( string-length( $substring-before-space ) &lt; number( $max-line-length ) ) and $substring-after-space">
        <xsl:comment>Call "chop" recursively to build up the string until it is just greater than the max length:</xsl:comment> 
        <xsl:variable name="return-value">
          <xsl:call-template name="chop">
            <xsl:with-param name="newstring" select="$substring-before-space"/>
            <xsl:with-param name="original-string" select="$substring-after-space"/>
            <xsl:with-param name="max-line-length" select="$max-line-length"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$return-value"/>
      </xsl:when>
      <xsl:when test="$newstring">
        <xsl:value-of select="$newstring"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>Return the whole string if it is already less than the max length:</xsl:comment>
        <xsl:value-of select="$substring-before-space"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
