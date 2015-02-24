<?xml version="1.0" encoding="utf-8"?>
<!-- From Mike Graves, MIT
     https://github.com/gravesm/kendallite/blob/master/kendallite/site/fgdc.xsl
  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output omit-xml-declaration="yes" />


    <!-- Variables controlling the elements and attributes used to create html
         output -->

    <!-- Top level heading element -->
    <xsl:variable name="heading-1" select="'h3'" />
    <xsl:attribute-set name="heading-1-attr" />

    <!-- Second level heading element -->
    <xsl:variable name="heading-2" select="'h4'" />
    <xsl:attribute-set name="heading-2-attr" />

    <!-- Third level heading element -->
    <xsl:variable name="heading-3" select="'h5'" />
    <xsl:attribute-set name="heading-3-attr" />

    <!-- Element used to wrap one or more key/value pairs -->
    <xsl:variable name="list" select="'dl'" />
    <xsl:attribute-set name="list-attr">
        <xsl:attribute name="class">dl-horizontal</xsl:attribute>
    </xsl:attribute-set>

    <!-- Element used to wrap a key in a key/value pair -->
    <xsl:variable name="key" select="'dt'" />
    <xsl:attribute-set name="key-attr" />

    <!-- Element used to wrap a value in a key/value pair -->
    <xsl:variable name="value" select="'dd'" />
    <xsl:attribute-set name="value-attr" />

    <!-- Element used to wrap content of a top level section -->
    <xsl:variable name="section-1" select="'section'" />
    <xsl:attribute-set name="section-1-attr" />

    <!-- Element used to wrap an entity/attribute definition -->
    <xsl:variable name="section-2" select="'section'" />
    <xsl:attribute-set name="section-2-attr" />


    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>


    <!-- Identification Information -->
    <xsl:template match="metadata/idinfo">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Identification Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="citation">
        <xsl:element name="{$heading-2}" use-attribute-sets="heading-2-attr">
            <xsl:text>Citation Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates select="citeinfo" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="descript">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Description</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="abstract">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Abstract'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="purpose">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Purpose'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="supplinf">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Supplemental Information'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="timeperd">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Time Period of Content</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates select="timeinfo|current" />
        </xsl:element>
    </xsl:template>

    <xsl:template match="current">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Currentness Reference'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="status">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Status</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="spdom">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Spatial Domain</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="keywords">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Keywords</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="accconst">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:call-template name="description">
                    <xsl:with-param name="term" select="'Access Constraints'" />
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="useconst">
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:call-template name="description">
                    <xsl:with-param name="term" select="'Use Constraints'" />
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="temporal/tempkt">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Temporal Keyword Thesaurus'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="temporal/tempkey">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Temporal Keyword'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="stratum/stratkey">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Stratum Keyword'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="stratum/stratkt">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Stratum Keyword Thesaurus'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="theme">
        <xsl:element name="{$key}" use-attribute-sets="key-attr">
            <xsl:attribute name="title">Theme Keywords</xsl:attribute>
            <xsl:text>Theme Keywords</xsl:text>
        </xsl:element>
        <xsl:element name="{$value}" use-attribute-sets="value-attr">
            <xsl:for-each select="themekey">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="place">
        <xsl:element name="{$key}" use-attribute-sets="key-attr">
            <xsl:attribute name="title">Place Keywords</xsl:attribute>
            <xsl:text>Place Keywords</xsl:text>
        </xsl:element>
        <xsl:element name="{$value}" use-attribute-sets="value-attr">
            <xsl:for-each select="placekey">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template match="westbc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'West Bounding Coordinate'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="eastbc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'East Bounding Coordinate'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="northbc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'North Bounding Coordinate'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="southbc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'South Bounding Coordinate'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="update">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Maintenance and Update Frequency'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="progress">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Progress'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="current">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Currentness Reference'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="ptcontac">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates select="cntinfo" />
        </xsl:element>
    </xsl:template>
    <!-- End Identification Information -->


    <!-- Data Quality Information -->
    <xsl:template match="metadata/dataqual">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Data Quality Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="attracc">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Attribute Accuracy</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="attraccr">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Attribute Accuracy Report'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="attraccv">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Attribute Accuracy Value'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="attracce">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Attribute Accuracy Explanation'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="logic">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:call-template name="description">
                <xsl:with-param name="term" select="'Logical Consistency Report'" />
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="complete">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:call-template name="description">
                <xsl:with-param name="term" select="'Completeness Report'" />
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template match="posacc/horizpa">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Horizontal Positional Accuracy</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="posacc/vertacc">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Vertical Positional Accuracy</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="horizpar">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Horizontal Positional Accuracy Report'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="qhorizpa">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="horizpav">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Horizontal Positional Accuracy Value'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="horizpae">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Horizontal Positional Accuracy Explanation'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vertaccr">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Vertical Positional Accuracy Report'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="qvertpa">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="vertaccv">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Vertical Positional Accuracy Value'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vertacce">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Vertical Positional Accuracy Explanation'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="lineage/srcinfo">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Lineage Source Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="srccite/citeinfo">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="lineage/procstep">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Lineage Process Step</xsl:text>
        </xsl:element>
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="procdesc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Process Description'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="srcused">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Source Used Citation Abbreviation'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="procdate">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Process Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="proctime">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Process Time'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="srcprod">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Source Produced Citation Abbreviation'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="proccont">
    </xsl:template>

    <xsl:template match="cloud">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Cloud Cover'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Data Quality Information -->

    <!-- Spatial Data Organization Information -->
    <xsl:template match="metadata/spdoinfo">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Spatial Data Organization Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1-attr">
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:apply-templates />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="indspref">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Indirect Spatial Reference'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="direct">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Direct Spatial Reference Method'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="sdtstype">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'SDTS Point and Vector Object Type'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="ptvctcnt">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Point and Vector Object Count'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vpflevel">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'VPF Topology Level'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vpftype">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'VPF Point and Vector Object Type'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="rasttype">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Raster Object Type'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="rowcount">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Row Count'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="colcount">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Column Count'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="vrtcount">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Vertical Count'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Spatial Data Organization Information -->


    <!-- Spatial Reference Information -->
    <xsl:template match="metadata/spref">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Spatial Reference Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1-attr">
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:apply-templates />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="horizsys">
        <xsl:element name="{$heading-2}" use-attribute-sets="hdgn-2-attr">
            <xsl:text>Horizontal Coordinate System Definition</xsl:text>
        </xsl:element>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="geograph">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="geodetic">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="latres">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Latitude Resolution'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="longres">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Longitude Resolution'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="geogunit">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Geographic Coordinate Units'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="horizdn">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Horizontal Datum Name'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="ellips">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Ellipsoid Name'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="semiaxis">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Semi-major Axis'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="denflat">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Denominator of Flattening Ratio'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Spatial Reference Information -->


    <!-- Entity and Attribute Information -->
    <xsl:template match="metadata/eainfo">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Entity and Attribute Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="detailed">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="overview">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="enttyp">
        <xsl:element name="{$heading-2}" use-attribute-sets="heading-2-attr">
            <xsl:value-of select="enttypl" />
        </xsl:element>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="attr">
        <xsl:element name="{$section-2}" use-attribute-sets="section-2-attr">
            <xsl:element name="{$heading-3}" use-attribute-sets="heading-3-attr">
                <xsl:value-of select="attrlabl" />
            </xsl:element>
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:apply-templates />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="attrdef">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Attribute Definition'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="attrdefs">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Attribute Definition Source'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="edom">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="edomv">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Enumerated Domain Value'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="edomvd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Enumerated Domain Value Definition'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="edomvds">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Enumerated Domain Value Definition Source'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="eaover">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Entity and Attribute Overview'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="eadetcit">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Entity and Attribute Detail Citation'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Entity and Attribute Information -->


    <!-- Distribution Information -->
    <xsl:template match="metadata/distinfo">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Distribution Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1-attr">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="distrib">
        <xsl:element name="{$list}" use-attribute-sets="list-attr">
            <xsl:apply-templates select="cntinfo" />
        </xsl:element>
    </xsl:template>
    <!-- End Distribution Information -->


    <!-- Metdata Reference Information -->
    <xsl:template match="metadata/metainfo">
        <xsl:element name="{$heading-1}" use-attribute-sets="heading-1-attr">
            <xsl:text>Metadata Reference Information</xsl:text>
        </xsl:element>
        <xsl:element name="{$section-1}" use-attribute-sets="section-1">
            <xsl:element name="{$list}" use-attribute-sets="list-attr">
                <xsl:apply-templates />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="metd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metrd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Review Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metfrd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Future Review Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metc">
        <xsl:apply-templates select="cntinfo" />
    </xsl:template>

    <xsl:template match="metstdn">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Standard Name'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metstdv">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Standard Version'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="mettc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Time Convention'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metac">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Access Constraints'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metuc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Use Constraints'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metscs">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Security Classification System'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metsc">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Security Classification'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metshd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Metadata Security Handling Description'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="metprof">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Profile Name'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Metadata Reference Information -->


    <!-- Time Period Information used by multiple sections -->
    <xsl:template match="timeinfo">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="sngdate/caldate">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Calendar Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="sngdate/time">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Time of Day'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Time Period Information -->


    <!-- Citation Information used by multiple sections -->
    <xsl:template match="citeinfo">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="origin">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Originator'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="pubdate">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Publication Date'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="pubtime">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Publication Time'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="title">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Title'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="edition">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Edition'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="geoform">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Geospatial Data Presentation Form'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="serinfo/sername">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Series Name'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="serinfo/issue">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Issue Identification'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="pubinfo/pubplace">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Publication Place'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="pubinfo/publish">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Publisher'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="othercit">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Other Citation Details'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="onlink">
        <xsl:call-template name="description-link">
            <xsl:with-param name="term" select="'Online Linkage'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Citation Information -->


    <!-- Contact Information used by multiple sections -->
    <xsl:template match="cntinfo">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="cntperp/cntper|cntorgp/cntper">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Person'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntperp/cntorg|cntorgp/cntorg">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Organization'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntpos">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Position'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntaddr">
        <xsl:element name="{$key}" use-attribute-sets="key-attr">
            <xsl:attribute name="title">Address Type</xsl:attribute>
            <xsl:text>Address Type</xsl:text>
        </xsl:element>
        <xsl:element name="{$value}" use-attribute-sets="value-attr">
            <xsl:value-of select="addrtype" />
        </xsl:element>
        <xsl:element name="{$key}" use-attribute-sets="key-attr">
            <xsl:attribute name="title">Address</xsl:attribute>
        </xsl:element>
        <xsl:element name="{$value}" use-attribute-sets="value-attr">
            <address>
                <xsl:value-of select="address" /><br />
                <xsl:value-of select="city" /><xsl:text>, </xsl:text>
                <xsl:value-of select="state" /><xsl:text> </xsl:text>
                <xsl:value-of select="postal" /><br />
                <xsl:value-of select="country" />
            </address>
        </xsl:element>
    </xsl:template>

    <xsl:template match="cntvoice">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Phone'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cnttdd">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'TDD/TTY'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntfax">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Fax'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntemail">
        <xsl:call-template name="description-email">
            <xsl:with-param name="term" select="'Email'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="hours">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Hours of Service'" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="cntinst">
        <xsl:call-template name="description">
            <xsl:with-param name="term" select="'Contact Instructions'" />
        </xsl:call-template>
    </xsl:template>
    <!-- End Citation Information -->


    <!-- Named templates used throughout stylesheet to generate k/v pairs -->
    <xsl:template name="description">
        <xsl:param name="term" />
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="{$key}" use-attribute-sets="key-attr">
                <xsl:attribute name="title">
                    <xsl:value-of select="$term" />
                </xsl:attribute>
                <xsl:value-of select="$term" />
            </xsl:element>
            <xsl:element name="{$value}" use-attribute-sets="value-attr">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="description-link">
        <xsl:param name="term" />
        <xsl:if test="normalize-space(.) != ''">
            <xsl:choose>
                <xsl:when test="starts-with(normalize-space(.), 'http')">
                    <xsl:element name="{$key}" use-attribute-sets="key-attr">
                        <xsl:attribute name="title">
                            <xsl:value-of select="$term" />
                        </xsl:attribute>
                        <xsl:value-of select="$term" />
                    </xsl:element>
                    <xsl:element name="{$value}" use-attribute-sets="value-attr">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="." />
                            </xsl:attribute>
                            <xsl:value-of select="." />
                        </xsl:element>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="description">
                        <xsl:with-param name="term" select="$term" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="description-email">
        <xsl:param name="term" />
        <xsl:if test="normalize-space(.) != ''">
            <xsl:element name="{$key}" use-attribute-sets="key-attr">
                <xsl:attribute name="title">
                    <xsl:value-of select="$term" />
                </xsl:attribute>
                <xsl:value-of select="$term" />
            </xsl:element>
            <xsl:element name="{$value}" use-attribute-sets="value-attr">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('mailto:', .)" />
                    </xsl:attribute>
                    <xsl:value-of select="." />
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <!-- Suppress unknown elements -->
    <xsl:template match="text()"></xsl:template>

</xsl:stylesheet>