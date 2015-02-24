<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema">
  
  <xs:annotation>
    <xs:documentation>
        Convert string-based enumerations within a schema to regular
        expressions which allow any combination of capitalization. Original
        version of this stylesheet obtained from:
        http://www.ibm.com/developerworks/xml/library/x-case/
    </xs:documentation>
  </xs:annotation>

  <xsl:template match="*|@*|text()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xs:restriction[@base='xs:string']
                       [count(xs:enumeration) &gt; 0]">
    <xs:restriction base="xs:string">
      <xs:pattern>
        <xsl:attribute name="value">
          <xsl:for-each select="xs:enumeration">

            <!-- Step 1. Write a left parenthesis -->
            <xsl:text>(</xsl:text>

            <!-- Step 2. Write the upper- and lowercase letters -->
            <xsl:call-template name="case-insensitive-pattern">
              <xsl:with-param name="index" select="1"/>
              <xsl:with-param name="string" select="@value"/>
            </xsl:call-template>

            <!-- Step 3. Write a right parenthesis -->
            <xsl:text>)</xsl:text>

            <!-- Step 4. If this isn't the last enumeration, write -->
            <!-- a vertical bar -->
            <xsl:if test="not(position()=last())">
              <xsl:text>|</xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xs:pattern>
    </xs:restriction>
  </xsl:template>

  <xsl:template name="case-insensitive-pattern">
    <xsl:param name="string"/>
    <xsl:param name="index"/>

    <xsl:variable name="current-letter">
      <!-- Write a left parenthesis -->
      <xsl:text>(</xsl:text>

      <!-- Convert the current letter to uppercase -->
      <xsl:value-of select="translate(substring($string, $index, 1), 
                                      'abcdefghijklmnopqrstuvwxyz', 
                                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>

      <!-- Write a vertical bar -->
      <xsl:text>|</xsl:text>

      <!-- Convert the current letter to lowercase -->
      <xsl:value-of select="translate(substring($string, $index, 1), 
                                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 
                                      'abcdefghijklmnopqrstuvwxyz')"/>

      <!-- Write a right parenthesis -->
      <xsl:text>)</xsl:text>
    </xsl:variable>

    <xsl:variable name="remaining-letters">

      <!-- If $index is less than the length of the string, -->
      <!-- call the template again. -->
      <xsl:if test="$index &lt; string-length($string)">
        <xsl:call-template name="case-insensitive-pattern">

          <!-- The string parameter doesn't change -->
          <xsl:with-param name="string" select="$string"/>

          <!-- Increment the index of the current letter by 1 -->
          <xsl:with-param name="index" select="$index+1"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <!-- Finally, we output the concatenated values -->
    <xsl:value-of select="concat($current-letter, $remaining-letters)"/>
  </xsl:template>

</xsl:stylesheet>
