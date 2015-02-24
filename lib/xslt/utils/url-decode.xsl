<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:template name="url-decode">
  
    <xsl:param name="in" as="xs:string"/>
    <xsl:param name="seq" as="xs:string*"/>

    <xsl:variable name="unreserved" as="xs:integer+"
      select="(45, 46, 48 to 57, 65 to 90, 95, 97 to 122, 126)"/>

    <xsl:choose>
      <xsl:when test="not($in)">
        <xsl:sequence select="string-join($seq, '')"/>
      </xsl:when>
      <xsl:when test="starts-with($in, '%')">
        <xsl:choose>
          <xsl:when test="matches(substring($in, 2, 2), '^[0-9A-Fa-f][0-9A-Fa-f]$')">
            <xsl:variable name="s" as="xs:string" select="substring($in, 2, 2)"/>
            <xsl:variable name="d" as="xs:integer" select="p:hex-to-dec(upper-case($s))"/>
            <xsl:choose>
              <xsl:when test="$d = $unreserved">
                <xsl:variable name="c" as="xs:string" select="codepoints-to-string($d)"/>
                <xsl:sequence select="p:pct-decode-unreserved(substring($in, 4), ($seq, $c))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="p:pct-decode-unreserved(substring($in, 4), ($seq, '%', $s))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="contains(substring($in, 2), '%')">
            <xsl:variable name="s" as="xs:string" select="substring-before(substring($in, 2), '%')"/>
            <xsl:sequence select="p:pct-decode-unreserved(substring($in, 2 + string-length($s)), ($seq, '%', $s))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="string-join(($seq, $in), '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($in, '%')">
        <xsl:variable name="s" as="xs:string" select="substring-before($in, '%')"/>
        <xsl:sequence select="p:pct-decode-unreserved(substring($in, string-length($s)+1), ($seq, $s))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="string-join(($seq, $in), '')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Private function to convert a hexadecimal string into decimal -->
  <xsl:function name="p:hex-to-dec" as="xs:integer">
    <xsl:param name="hex" as="xs:string"/>

    <xsl:variable name="len" as="xs:integer" select="string-length($hex)"/>
    <xsl:choose>
      <xsl:when test="$len eq 0">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:when test="$len eq 1">
        <xsl:sequence select="
                 if ($hex eq '0')       then 0
            else if ($hex eq '1')       then 1
            else if ($hex eq '2')       then 2
            else if ($hex eq '3')       then 3
            else if ($hex eq '4')       then 4
            else if ($hex eq '5')       then 5
            else if ($hex eq '6')       then 6
            else if ($hex eq '7')       then 7
            else if ($hex eq '8')       then 8
            else if ($hex eq '9')       then 9
            else if ($hex = ('A', 'a')) then 10
            else if ($hex = ('B', 'b')) then 11
            else if ($hex = ('C', 'c')) then 12
            else if ($hex = ('D', 'd')) then 13
            else if ($hex = ('E', 'e')) then 14
            else if ($hex = ('F', 'f')) then 15
            else error(xs:QName('p:hex-to-dec'))
          "/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          (16 * p:hex-to-dec(substring($hex, 1, $len - 1)))
          + p:hex-to-dec(substring($hex, $len))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
