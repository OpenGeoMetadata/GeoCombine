<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!-- 
     fgdc2html.xsl - Transformation from CDSDGM/FGDC into HTML 
     Created by Kim Durante, Stanford University Libraries

     -->
  <xsl:template match="/">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
    <html>
      <head>
        <title>
          <xsl:value-of select="metadata/idinfo/citation/citeinfo/title" />
        </title>
      </head>
      <body>
        <h1>
          <xsl:value-of select="metadata/idinfo/citation/citeinfo/title" />
        </h1>
        <ul>
          <xsl:for-each select="metadata/idinfo">
            <li>
              <a href="#fgdc-identification-info">Identification Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/dataqual">
            <li>
              <a href="#fgdc-data-quality-info">Data Quality Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/spdoinfo">
            <li>
              <a href="#fgdc-spatialdataorganization-info">Spatial Data Organization Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/spref">
            <li>
              <a href="#fgdc-spatialreference-info">Spatial Reference Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/eainfo">
            <li>
              <a href="#fgdc-entityattribute-info">Entity and Attribute Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/distinfo">
            <li>
              <a href="#fgdc-distribution-info">Distribution Information</a>
            </li>
          </xsl:for-each>
          <xsl:for-each select="metadata/metainfo">
            <li>
              <a href="#fgdc-metadata-reference-info">Metadata Reference Information</a>
            </li>
          </xsl:for-each>
        </ul>
        <xsl:apply-templates select="metadata/idinfo" />
        <xsl:apply-templates select="metadata/dataqual" />
        <xsl:apply-templates select="metadata/spdoinfo" />
        <xsl:apply-templates select="metadata/spref" />
        <xsl:apply-templates select="metadata/eainfo" />
        <xsl:apply-templates select="metadata/distinfo" />
        <xsl:apply-templates select="metadata/metainfo" />
      </body>
    </html>
  </xsl:template>
  <!-- Identification -->
  <xsl:template match="idinfo">
    <div id="fgdc-identification-info">
      <dl>
        <dt>Identification Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="citation">
              <dt>Citation</dt>
              <dd>
                <xsl:apply-templates select="citeinfo" />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="descript/abstract">
              <dt>Abstract</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="descript/purpose">
              <dt>Purpose</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="descrip/supplinf">
              <dt>Supplemental Information</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="timeperd">
              <dt>Temporal Extent</dt>
              <dd>
                <dl>
                  <xsl:for-each select="current">
                    <dt>Currentness Reference</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:choose>
                    <xsl:when test="timeinfo/sngdate">
                      <dt>Time Instant</dt>
                      <dd>
                        <xsl:value-of select="timeinfo/sngdate/caldate" />
                      </dd>
                    </xsl:when>
                    <xsl:when test="timeinfo/rngdates">
                      <dt>Time Period</dt>
                      <dd>
                        <dl>
                          <dt>Beginning</dt>
                          <dd>
                            <xsl:value-of select="timeinfo/rngdates/begdate" />
                          </dd>
                          <dt>End</dt>
                          <dd>
                            <xsl:value-of select="timeinfo/rngdates/enddate" />
                          </dd>
                        </dl>
                      </dd>
                    </xsl:when>
                  </xsl:choose>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="spdom/bounding">
              <dt>Bounding Box</dt>
              <dd>
                <dl>
                  <dt>West</dt>
                  <dd>
                    <xsl:value-of select="westbc" />
                  </dd>
                  <dt>East</dt>
                  <dd>
                    <xsl:value-of select="eastbc" />
                  </dd>
                  <dt>North</dt>
                  <dd>
                    <xsl:value-of select="northbc" />
                  </dd>
                  <dt>South</dt>
                  <dd>
                    <xsl:value-of select="southbc" />
                  </dd>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="keywords/theme">
              <xsl:choose>
                <xsl:when test="themekt/text()='ISO 19115 Topic Category'">
                  <dt>ISO Topic Category</dt>
                  <xsl:for-each select="themekey">
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <dt>Theme Keyword</dt>
                  <xsl:for-each select="ancestor-or-self::*/themekey">
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                    <xsl:if test="position()=last()">
                      <dd>
                        <dl>
                          <dt>Theme Keyword Thesaurus</dt>
                          <dd>
                            <xsl:value-of select="ancestor-or-self::*/themekt" />
                          </dd>
                        </dl>
                      </dd>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <dt>Place Keyword</dt>
            <xsl:for-each select="keywords/place/placekey">
              <dd>
                <xsl:value-of select="." />
              </dd>
              <xsl:if test="position()=last()">
                <dd>
                  <dl>
                    <dt>Place Keyword Thesaurus</dt>
                    <dd>
                      <xsl:value-of select="ancestor-or-self::*/placekt" />
                    </dd>
                  </dl>
                </dd>
              </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="accconst">
              <dt>Access Restrictions</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="useconst">
              <dt>Use Restrictions</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="status/progress">
              <dt>Status</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="status/update">
              <dt>Maintenance and Update Frequency</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="ptcontac">
              <dt>Point of Contact</dt>
              <dd>
                <dl>
                  <xsl:for-each select="cntinfo/cntperp/cntper">
                    <dt>Contact Person</dt>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntorgp/cntorg">
                    <dt>Contact Organization</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntpos">
                    <dt>Contact Position</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntaddr/address">
                    <dt>Delivery Point</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntaddr/city">
                    <dt>City</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntaddr/state">
                    <dt>State</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntaddr/postal">
                    <dt>Postal Code</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinfo/cntaddr/country">
                    <dt>Country</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntvoice">
                    <dt>Contact Telephone</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntfax">
                    <dt>Contact Facsimile Telephone</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntemail">
                    <dt>Contact Electronic Mail Address</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="hours">
                    <dt>Hours of Service</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="cntinst">
                    <dt>Contact Instructions</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="datacred">
              <dt>Credit</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="native">
              <dt>Native Data Set Environment</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="citation/citeinfo/lworkcit">
              <dt>Collection</dt>
              <dd>
                <xsl:apply-templates select="citeinfo" />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="crossref">
              <dt>Cross-Reference</dt>
              <dd>
                <xsl:apply-templates select="citeinfo" />
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Data Quality -->
  <xsl:template match="dataqual">
    <div id="fgdc-data-quality-info">
      <dl>
        <dt>Data Quality Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="attracc/attraccr">
              <dt>Attribute Accuracy Report</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="attracc/qattracc">
              <dt>Quantitative Attribute Accuracy Assessment</dt>
              <dd>
                <dl>
                  <xsl:for-each select="attracc/attraccv">
                    <dt>Attribute Accuracy Value</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="attracc/attracce">
                    <dt>Attribute Accuracy Explanation</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="logic">
              <dt>Logical Consistency Report</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="complete">
              <dt>Completeness Report</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="posacc/horizpa/horizpar">
              <dt>Horizontal Positional Accuracy Report</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="posacc/horizpa/qhorizpa">
              <dt>Quantitative Horizontal Positional Accuracy Assessment</dt>
              <dd>
                <dl>
                  <xsl:for-each select="posacc/horizpa/horizpav">
                    <dt>Horizontal Positional Accuracy Value</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="posacc/horizpa/horizpae">
                    <dt>Horizontal Positional Accuracy Explanation</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="vertacc/vertaccr">
              <dt>Vertical Positional Accuracy Report</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="vertacc/qvertpa">
              <dt>Quantitative Vertical Positional Accuracy Assessment</dt>
              <dd>
                <dl>
                  <xsl:for-each select="vertacc/vertaccv">
                    <dt>Vertical Positional Accuracy Value</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="vertacc/vertacce">
                    <dt>Vertical Positional Accuracy Explanation</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="lineage">
              <dt>Lineage</dt>
              <xsl:for-each select="srcinfo">
                <dd>
                  <dl>
                    <xsl:for-each select="srccite">
                      <dt>Source</dt>
                      <dd>
                        <dl>
                          <xsl:apply-templates select="citeinfo" />
                          <xsl:for-each select="ancestor-or-self::*/srcscale">
                            <dt>Source Scale Denominator</dt>
                            <dd>
                              <xsl:value-of select="." />
                            </dd>
                          </xsl:for-each>
                          <xsl:for-each select="ancestor-or-self::*/typesrc">
                            <dt>Type of Source Media</dt>
                            <dd>
                              <xsl:value-of select="." />
                            </dd>
                          </xsl:for-each>
                          <xsl:for-each select="ancestor-or-self::*/srctime">
                            <dt>Source Temporal Extent</dt>
                            <dd>
                              <dl>
                                <dd>
                                  <xsl:apply-templates select="timeinfo" />
                                </dd>
                                <xsl:for-each select="srccurr">
                                  <dt>Source Currentness Reference</dt>
                                  <dd>
                                    <xsl:value-of select="." />
                                  </dd>
                                </xsl:for-each>
                              </dl>
                            </dd>
                          </xsl:for-each>
                        </dl>
                      </dd>
                    </xsl:for-each>
                  </dl>
                  <xsl:for-each select="procstep">
                    <dt>Process Step</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="procdesc">
                          <dt>Description</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="srcused">
                          <dt>Source Used Citation Abbreviation</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="procdate">
                          <dt>Process Date</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="proctime">
                          <dt>Process Time</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="srcprod">
                          <dt>Source Produced Citation Abbreviation</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="proccont">
                          <dt>Process Contact</dt>
                          <dd>
                            <dl>
                              <xsl:apply-templates select="cntinfo" />
                            </dl>
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dd>
              </xsl:for-each>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Spatial Data Organization -->
  <xsl:template match="spdoinfo">
    <div id="fgdc-spatialdataorganization-info">
      <dl>
        <dt>Spatial Data Organization Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="indspref">
              <dt>Indirect Spatial Reference Method</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="direct">
              <dt>Direct Spatial Reference Method</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="ptvctinf">
              <dt>Point and Vector Object Information</dt>
              <dd>
                <dl>
                  <xsl:for-each select="sdtsterm">
                    <dt>SDTS Terms Description</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="sdtstype">
                          <dt>SDTS Point and Vector Object Type</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="ptvctcnt">
                          <dt>Point and Vector Object Count</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="vpfterm">
                    <dt>VPF Terms Description</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="vpflevel">
                          <dt>VPF Topology Level</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="vpfinfo">
                          <dt>VPF Point and Vector Object Information</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="vpftype">
                                <dt>VPF Point and Vector Object Type</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="ptvctcnt">
                                <dt>Point and Vector Object Count</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="rastinfo">
              <dt>Raster Object Information</dt>
              <dd>
                <dl>
                  <xsl:for-each select="rasttype">
                    <dt>Raster Object Type</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="rowcount">
                    <dt>Row Count</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="colcount">
                    <dt>Column Count</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="vrtcount">
                    <dt>Vertical Count</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Spatial Reference -->
  <xsl:template match="spref">
    <div id="fgdc-spatialreference-info">
      <dl>
        <dt>Spatial Reference Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="horizsys">
              <dt>Horizontal Coordinate System Definition</dt>
              <dd>
                <dl>
                  <xsl:for-each select="geograph">
                    <dt>Geographic</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="latres">
                          <dt>Latitude Resolution</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="longres">
                          <dt>Longitude Resolution</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="geogunit">
                          <dt>Geographic Coordinate Units</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="planar">
                    <dt>Planar</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="mapproj">
                          <dt>Map Projection</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="mapprojn">
                                <dt>Map Projection Name</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="albers">
                                <dt>Albers Conical Equal Area</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="azimequi">
                                <dt>Azimuthal Equidistant</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="equicon">
                                <dt>Equidistant Conic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="equirect">
                                <dt>Equirectangular</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="gvnsp">
                                <dt>General Vertical Near-sided Perspective</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="gnomonic">
                                <dt>Gnomonic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="lamberta">
                                <dt>Lambert Azimuthal Equal Area</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="lambertc">
                                <dt>Lambert Conformal Conic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="mercator">
                                <dt>Mercator</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="miller">
                                <dt>Miller Cylindrical</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="obqmerc">
                                <dt>Oblique Mercator</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="orthogr">
                                <dt>Orthographic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="polarst">
                                <dt>Polar Stereographic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="polycon">
                                <dt>Polyconic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="sinusoid">
                                <dt>Sinusoidal</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="stereo">
                                <dt>Stereographic</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="transmer">
                                <dt>Transverse Mercator</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="vdgrin">
                                <dt>van der Grinten</dt>
                                <dd>
                                  <xsl:apply-templates select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="otherprj">
                                <dt>Other Projection's Definition</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="gridsys">
                          <dt>Grid Coordinate System</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="gridsysn">
                                <dt>Grid Coordinate System Name</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="utm">
                                <dt>Universal Transverse Mercator</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="utmzone">
                                      <dt>UTM Zone Number</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="transmer">
                                      <dt>Transverse Mercator</dt>
                                    </xsl:for-each>
                                    <xsl:apply-templates select="transmer" />
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="ups">
                                <dt>Universal Polar Stereographic</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="upszone">
                                      <dt>UPS Zone Identifier</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="polarst">
                                      <dt>Polar Stereographic</dt>
                                    </xsl:for-each>
                                    <xsl:apply-templates select="polarst" />
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="spcs">
                                <dt>State Plane Coordinate System</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="spcszone">
                                      <dt>SPCS Zone Identifier</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="lambertc">
                                      <dt>Lambert Conformal Conic</dt>
                                      <dd>
                                        <xsl:apply-templates select="lambertc" />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="transmer">
                                      <dt>Transverse Mercator</dt>
                                      <dd>
                                        <xsl:apply-templates select="transmer" />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="obqmerc">
                                      <dt>Oblique Mercator</dt>
                                      <dd>
                                        <xsl:apply-templates select="obqmerc" />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="polycon">
                                      <dt>Polyconic</dt>
                                      <dd>
                                        <xsl:apply-templates select="polycon" />
                                      </dd>
                                    </xsl:for-each>
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="arcsys">
                                <dt>ARC Coordinate System</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="arczone">
                                      <dt>ARC System Zone Identifier</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="equirect">
                                      <dt>Equirectangular</dt>
                                    </xsl:for-each>
                                    <dd>
                                      <xsl:apply-templates select="equirect" />
                                    </dd>
                                    <xsl:for-each select="azimequi">
                                      <dt>Azimuthal Equidistant</dt>
                                      <dd>
                                        <xsl:apply-templates select="azimequi" />
                                      </dd>
                                    </xsl:for-each>
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="othergrd">
                                <dt>Other Grid System's Definition</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="localp">
                          <dt>Local Planar</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="localpd">
                                <dt>Local Planar Description</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="localpgi">
                                <dt>Local Planar Georeference Information</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="planci">
                          <dt>Planar Coordinate Information</dt>
                          <dd>
                            <dl>
                              <xsl:for-each select="plance">
                                <dt>Planar Coordinate Encoding Method</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="coordrep">
                                <dt>Coordinate Representation</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="absres">
                                      <dt>Abscissa Resolution</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="ordres">
                                      <dt>Ordinate Resolution</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="distbrep">
                                <dt>Distance and Bearing Representation</dt>
                                <dd>
                                  <dl>
                                    <xsl:for-each select="distres">
                                      <dt>Distance Resolution</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="bearres">
                                      <dt>Bearing Resolution</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="bearunit">
                                      <dt>Bearing Units</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="bearrefd">
                                      <dt>Bearing Reference Direction</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                    <xsl:for-each select="bearrefm">
                                      <dt>Bearing Reference Meridian</dt>
                                      <dd>
                                        <xsl:value-of select="." />
                                      </dd>
                                    </xsl:for-each>
                                  </dl>
                                </dd>
                              </xsl:for-each>
                              <xsl:for-each select="plandu">
                                <dt>Planar Distance Units</dt>
                                <dd>
                                  <xsl:value-of select="." />
                                </dd>
                              </xsl:for-each>
                            </dl>
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="local">
                    <dt>Local</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="localdes">
                          <dt>Local Description</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="localgeo">
                          <dt>Local Georeference Information</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="geodetic">
                    <dt>Geodetic Model</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="horizdn">
                          <dt>Horizontal Datum Name</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="ellips">
                          <dt>Ellipsoid Name</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="semiaxis">
                          <dt>Semi-major Axis</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="denflat">
                          <dt>Denominator of Flattening Ratio</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="vertdef">
              <dt>Vertical Coordinate System Definition</dt>
              <dd>
                <dl>
                  <xsl:for-each select="altsys">
                    <dt>Altitude System Definition</dt>
                    <dd>
                      <dl>
                        <xsl:for-each select="altdatum">
                          <dt>Altitude Datum Name</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="altres">
                          <dt>Altitude Resolution</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="altunits">
                          <dt>Altitude Distance Units</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                        <xsl:for-each select="altenc">
                          <dt>Altitude Encoding Method</dt>
                          <dd>
                            <xsl:value-of select="." />
                          </dd>
                        </xsl:for-each>
                      </dl>
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Entity and Attribute -->
  <xsl:template match="eainfo">
    <div id="fgdc-entityattribute-info">
      <dl>
        <dt>Entity and Attribute Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="detailed">
              <xsl:for-each select="enttyp">
                <dt>Entity Type</dt>
                <dd>
                  <dl>
                    <xsl:for-each select="enttypl">
                      <dt>Entity Type Label</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="enttypd">
                      <dt>Entity Type Definition</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="enttypds">
                      <dt>Entity Type Definition Source</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                  </dl>
                </dd>
              </xsl:for-each>
              <xsl:apply-templates select="attr" />
            </xsl:for-each>
            <xsl:for-each select="overview">
              <xsl:for-each select="eaover">
                <dt>Entity and Attribute Overview</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="eadetcit">
                <dt>Entity and Attribute Detail Citation</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Distribution -->
  <xsl:template match="distinfo">
    <div id="fgdc-distribution-info">
      <dl>
        <dt>Distribution Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="stdorder/digform/digtinfo/formname">
              <dt>Format Name</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="distrib/cntinfo/cntorgp/cntorg">
              <dt>Distributor</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="stdorder/digform/digtopt/onlinopt/computer/networka/networkr">
              <dt>Online Access</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="//metadata/idinfo/citation/citeinfo/onlink">
              <dt>Name</dt>
              <dd>
                <xsl:value-of select="substring-after(.,'VCollName=')" />
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Metadata -->
  <xsl:template match="metainfo">
    <div id="fgdc-metadata-reference-info">
      <dl>
        <dt>Metadata Reference Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="metd">
              <dt>Metadata Date</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="metrd">
              <dt>Metadata Review Date</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="metc">
              <dt>Metadata Contact</dt>
              <dd>
                <dl>
                  <xsl:apply-templates select="cntinfo" />
                </dl>
              </dd>
            </xsl:for-each>
            <xsl:for-each select="metstdn">
              <dt>Metadata Standard Name</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="metstdv">
              <dt>Metadata Standard Version</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="metextns">
              <dt>Metadata Extensions</dt>
              <dd>
                <dl>
                  <xsl:for-each select="onlink">
                    <dt>Online Linkage</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                  <xsl:for-each select="metprof">
                    <dt>Profile Name</dt>
                    <dd>
                      <xsl:value-of select="." />
                    </dd>
                  </xsl:for-each>
                </dl>
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </dl>
    </div>
  </xsl:template>
  <!-- Citation -->
  <xsl:template match="citeinfo">
    <dl>
      <xsl:for-each select="origin">
        <dt>Originator</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="pubdate">
        <dt>Publication Date</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="pubtime">
        <dt>Publication Time</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="title">
        <dt>Title</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="edition">
        <dt>Edition</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="geoform">
        <dt>Geospatial Data Presentation Form</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="lworkcit/citeinfo/title">
        <dt>Collection Title</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="serinfo">
        <dt>Series Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="sername">
              <dt>Series Name</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="issue">
              <dt>Issue Identification</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </xsl:for-each>
      <xsl:for-each select="pubinfo">
        <dt>Publication Information</dt>
        <dd>
          <dl>
            <xsl:for-each select="pubplace">
              <dt>Publication Place</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
            <xsl:for-each select="publish">
              <dt>Publisher</dt>
              <dd>
                <xsl:value-of select="." />
              </dd>
            </xsl:for-each>
          </dl>
        </dd>
      </xsl:for-each>
      <xsl:for-each select="othercit">
        <dt>Other Citation Details</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
      <xsl:for-each select="onlink">
        <dt>Online Linkage</dt>
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
    </dl>
  </xsl:template>
  <!-- Contact -->
  <xsl:template match="cntinfo">
    <dt>Contact Information</dt>
    <dd>
      <dl>
        <xsl:for-each select="cntperp">
          <dt>Contact Person Primary</dt>
          <dd>
            <dl>
              <xsl:for-each select="cntper">
                <dt>Contact Person</dt>
              </xsl:for-each>
              <xsl:for-each select="cntorg">
                <dt>Contact Organization</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </dl>
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntorgp">
          <dt>Contact Organization Primary</dt>
          <dd>
            <dl>
              <xsl:for-each select="cntorg">
                <dt>Contact Organization</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="cntper">
                <dt>Contact Person</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </dl>
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntpos">
          <dt>Contact Position</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntaddr">
          <dt>Contact Address</dt>
          <dd>
            <dl>
              <xsl:for-each select="address">
                <dt>Address</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="city">
                <dt>City</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="state">
                <dt>State or Province</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="postal">
                <dt>Postal Code</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="country">
                <dt>Country</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </dl>
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntvoice">
          <dt>Contact Voice Telephone</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntfax">
          <dt>Contact Facsimile Telephone</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntemail">
          <dt>Contact Electronic Mail Address</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="hours">
          <dt>Hours of Service</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="cntinst">
          <dt>Contact Instructions</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
  <!-- Time Period Info -->
  <xsl:template match="timeinfo">
    <dt>Time Period Information</dt>
    <dd>
      <dl>
        <xsl:apply-templates select="sngdate" />
        <xsl:apply-templates select="mdattim" />
        <xsl:apply-templates select="rngdates" />
      </dl>
    </dd>
  </xsl:template>
  <!-- Single Date/Time -->
  <xsl:template match="sngdate">
    <dt>Single Date/Time</dt>
    <dd>
      <dl>
        <xsl:for-each select="caldate">
          <dt>Calendar Date</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="time">
          <dt>Time of Day</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
  <!-- Multiple Date/Time -->
  <xsl:template match="mdattim">
    <dt>Multiple Dates/Times</dt>
    <dd>
      <dl>
        <xsl:apply-templates select="sngdate" />
      </dl>
    </dd>
  </xsl:template>
  <!-- Range of Dates/Times -->
  <xsl:template match="rngdates">
    <dt>Range of Dates/Times</dt>
    <dd>
      <dl>
        <xsl:for-each select="begdate">
          <dt>Beginning Date</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="begtime">
          <dt>Beginning Time</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="enddate">
          <dt>Ending Date</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="endtime">
          <dt>Ending Time</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
  <!-- G-Ring -->
  <xsl:template match="grngpoin">
    <dt>G-Ring Point</dt>
    <dd>
      <dl>
        <xsl:for-each select="gringlat">
          <dt>G-Ring Latitude</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="gringlon">
          <dt>G-Ring Longitude</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="gring">
    <dt>G-Ring</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <!-- Map Projections -->
  <xsl:template match="albers | equicon | lambertc">
    <dd>
      <dl>
        <xsl:apply-templates select="stdparll" />
        <xsl:apply-templates select="longcm" />
        <xsl:apply-templates select="latprjo" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="gnomonic | lamberta | orthogr | stereo | gvnsp">
    <dd>
      <dl>
        <xsl:for-each select="../gvnsp">
          <xsl:apply-templates select="heightpt" />
        </xsl:for-each>
        <xsl:apply-templates select="longpc" />
        <xsl:apply-templates select="latprjc" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="miller | sinusoid | vdgrin | equirect | mercator">
    <dd>
      <dl>
        <xsl:for-each select="../equirect">
          <xsl:apply-templates select="stdparll" />
        </xsl:for-each>
        <xsl:for-each select="../mercator">
          <xsl:apply-templates select="stdparll" />
          <xsl:apply-templates select="sfequat" />
        </xsl:for-each>
        <xsl:apply-templates select="longcm" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="azimequi | polycon">
    <dd>
      <dl>
        <xsl:apply-templates select="longcm" />
        <xsl:apply-templates select="latprjo" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="transmer">
    <dd>
      <dl>
        <xsl:apply-templates select="sfctrmer" />
        <xsl:apply-templates select="longcm" />
        <xsl:apply-templates select="latprjo" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="polarst">
    <dd>
      <dl>
        <xsl:apply-templates select="svlong" />
        <xsl:apply-templates select="stdparll" />
        <xsl:apply-templates select="sfprjorg" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="obqmerc">
    <dd>
      <dl>
        <xsl:apply-templates select="sfctrlin" />
        <xsl:apply-templates select="obqlazim" />
        <xsl:apply-templates select="obqlpt" />
        <xsl:apply-templates select="latprjo" />
        <xsl:apply-templates select="feast" />
        <xsl:apply-templates select="fnorth" />
      </dl>
    </dd>
  </xsl:template>
  <!-- Map Projection Parameters -->
  <xsl:template match="stdparll">
    <dt>Standard Parallel</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="longcm">
    <dt>Longitude of Central Meridian</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="latprjo">
    <dt>Latitude of Projection Origin</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="feast">
    <dt>False Easting</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="fnorth">
    <dt>False Northing</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="sfequat">
    <dt>Scale Factor at Equator</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="heightpt">
    <dt>Height of Perspective Point Above Surface</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="longpc">
    <dt>Longitude of Projection Center</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="latprjc">
    <dt>Latitude of Projection Center</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="sfctrlin">
    <dt>Scale Factor at Center Line</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="obqlazim">
    <dt>Oblique Line Azimuth</dt>
    <dd>
      <dl>
        <xsl:for-each select="azimangl">
          <dt>Azimuthal Angle</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="azimptl">
          <dt>Azimuthal Measure Point Longitude</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
  <xsl:template match="svlong">
    <dt>Straight Vertical Longitude from Pole</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="sfprjorg">
    <dt>Scale Factor at Projection Origin</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="landsat">
    <dt>Landsat Number</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="pathnum">
    <dt>Path Number</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="sfctrmer">
    <dt>Scale Factor at Central Meridian</dt>
    <dd>
      <xsl:value-of select="." />
    </dd>
  </xsl:template>
  <xsl:template match="attr">
    <dt>Attribute</dt>
    <dd>
      <dl>
        <xsl:for-each select="attrlabl">
          <dt>Attribute Label</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="attrdef">
          <dt>Attribute Definition</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="attrdefs">
          <dt>Attribute Definition Source</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="attrdomv">
          <dt>Attribute Domain Values</dt>
          <dd>
            <dl>
              <xsl:for-each select="edom">
                <dt>Enumerated Domain</dt>
                <dd>
                  <dl>
                    <xsl:for-each select="edomv">
                      <dt>Enumerated Domain Value</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="edomvd">
                      <dt>Enumerated Domain Value Definition</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="edomvds">
                      <dt>Enumerated Domain Value Definition Source</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:apply-templates select="attr" />
                  </dl>
                </dd>
              </xsl:for-each>
              <xsl:for-each select="rdom">
                <dt>Range Domain</dt>
                <dd>
                  <dl>
                    <xsl:for-each select="rdommin">
                      <dt>Range Domain Minimum</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="rdommax">
                      <dt>Range Domain Maximum</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="attrunit">
                      <dt>Attribute Units of Measure</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="attrmres">
                      <dt>Attribute Measurement Resolution</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:apply-templates select="attr" />
                  </dl>
                </dd>
              </xsl:for-each>
              <xsl:for-each select="codesetd">
                <dt>Codeset Domain</dt>
                <dd>
                  <dl>
                    <xsl:for-each select="codesetn">
                      <dt>Codeset Name</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                    <xsl:for-each select="codesets">
                      <dt>Codeset Source</dt>
                      <dd>
                        <xsl:value-of select="." />
                      </dd>
                    </xsl:for-each>
                  </dl>
                </dd>
              </xsl:for-each>
              <xsl:for-each select="udom">
                <dt>Unrepresentable Domain</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </dl>
          </dd>
        </xsl:for-each>
        <xsl:for-each select="begdatea">
          <dt>Beginning Date of Attribute Values</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="enddatea">
          <dt>Ending Date of Attribute Values</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
        <xsl:for-each select="attrvai">
          <dt>Attribute Value Accuracy Information</dt>
          <dd>
            <dl>
              <xsl:for-each select="attrva">
                <dt>Attribute Value Accuracy</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
              <xsl:for-each select="attrvae">
                <dt>Attribute Value Accuracy Explanation</dt>
                <dd>
                  <xsl:value-of select="." />
                </dd>
              </xsl:for-each>
            </dl>
          </dd>
        </xsl:for-each>
        <xsl:for-each select="attrmfrq">
          <dt>Attribute Measurement Frequency</dt>
          <dd>
            <xsl:value-of select="." />
          </dd>
        </xsl:for-each>
      </dl>
    </dd>
  </xsl:template>
</xsl:stylesheet>
