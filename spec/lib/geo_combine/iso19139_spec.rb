# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeoCombine::Iso19139 do
  include XmlDocs

  let(:iso_object) { described_class.new(stanford_iso) }

  describe '#initialize' do
    it 'returns an instantiated Iso19139 object' do
      expect(iso_object).to be_an described_class
    end
  end

  describe '#xsl_geoblacklight' do
    it 'is defined' do
      expect(iso_object.xsl_geoblacklight).to be_an Nokogiri::XSLT::Stylesheet
    end
  end

  describe '#xsl_aardvark' do
    it 'is defined' do
      expect(iso_object.xsl_aardvark).to be_an Nokogiri::XSLT::Stylesheet
    end
  end

  describe '#xsl_html' do
    it 'is defined' do
      expect(iso_object.xsl_html).to be_an Nokogiri::XSLT::Stylesheet
    end
  end

  describe '#to_geoblacklight' do
    let(:valid_geoblacklight) { iso_object.to_geoblacklight('layer_geom_type_s' => 'Polygon') }

    it 'creates a GeoCombine::Geoblacklight object' do
      expect(valid_geoblacklight).to be_an GeoCombine::Geoblacklight
    end

    it 'is valid GeoBlacklight-Schema' do
      valid_geoblacklight.enhance_metadata
      expect(valid_geoblacklight).to be_valid
    end

    it 'has geoblacklight_version' do
      expect(valid_geoblacklight.metadata['geoblacklight_version']).to eq '1.0'
    end

    it 'has dc_creator_sm' do
      expect(valid_geoblacklight.metadata['dc_creator_sm']).to be_an Array
      expect(valid_geoblacklight.metadata['dc_creator_sm']).to eq ['Circuit Rider Productions']
    end

    it 'has dc_publisher_sm' do
      expect(valid_geoblacklight.metadata['dc_publisher_sm']).to be_an Array
      expect(valid_geoblacklight.metadata['dc_publisher_sm']).to eq ['Circuit Rider Productions']
    end
  end

  describe '#to_aardvark' do
    let(:iso_aardvark) { iso_object.to_aardvark }

    it 'returns a GeoCombine::GeoblacklightAardvark object' do
      expect(iso_aardvark).to be_an GeoCombine::GeoblacklightAardvark
    end

    it 'is valid Aardvark' do
      expect(iso_aardvark).to be_valid
    end

    describe 'with Aardvark schema fields' do
      it 'dct_title_s' do
        expect(iso_aardvark.metadata['dct_title_s'])
          .to eq 'Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999'
      end

      it 'dct_description_sm labels each source element' do
        expect(iso_aardvark.metadata['dct_description_sm'].size).to eq 2
        expect(iso_aardvark.metadata['dct_description_sm'].first).to start_with 'Abstract: This polygon dataset'
        expect(iso_aardvark.metadata['dct_description_sm'].last).to start_with 'Purpose: This shapefile'
      end

      it 'dct_language_sm' do
        expect(iso_aardvark.metadata['dct_language_sm']).to eq ['eng']
      end

      it 'dct_creator_sm' do
        expect(iso_aardvark.metadata['dct_creator_sm']).to eq ['Circuit Rider Productions']
      end

      it 'dct_publisher_sm' do
        expect(iso_aardvark.metadata['dct_publisher_sm']).to eq ['Circuit Rider Productions']
      end

      it 'schema_provider_s' do
        expect(iso_aardvark.metadata['schema_provider_s']).to eq 'Stanford Geospatial Center'
      end

      it 'gbl_resourceClass_sm' do
        expect(iso_aardvark.metadata['gbl_resourceClass_sm']).to eq ['Datasets']
      end

      it 'does not guess gbl_resourceType_sm from a composite geometry' do
        expect(iso_object.metadata.at_xpath('//gmd:MD_GeometricObjectTypeCode/@codeListValue', namespaces).value)
          .to eq 'composite'
        expect(iso_aardvark.metadata).not_to have_key 'gbl_resourceType_sm'
      end

      it 'dct_subject_sm keeps only the theme keywords' do
        expect(iso_aardvark.metadata['dct_subject_sm']).to eq %w[Hydrology Watersheds]
      end

      it 'dcat_theme_sm maps the ISO topic categories' do
        expect(iso_aardvark.metadata['dcat_theme_sm']).to eq ['Boundaries', 'Inland Waters']
      end

      it 'dcat_keyword_sm takes the keywords without a type' do
        expect(iso_aardvark.metadata['dcat_keyword_sm']).to eq ['Downloadable Data']
      end

      it 'dct_temporal_sm de-duplicates the time period and the temporal keyword' do
        expect(iso_aardvark.metadata['dct_temporal_sm']).to eq ['1999']
      end

      it 'dct_issued_s' do
        expect(iso_aardvark.metadata['dct_issued_s']).to eq '2002-09-01'
      end

      it 'gbl_indexYear_im' do
        expect(iso_aardvark.metadata['gbl_indexYear_im']).to eq [1999]
      end

      it 'gbl_dateRange_drsim' do
        expect(iso_aardvark.metadata['gbl_dateRange_drsim']).to eq ['[1999 TO 1999]']
      end

      it 'dct_spatial_sm' do
        expect(iso_aardvark.metadata['dct_spatial_sm'])
          .to eq ['Sonoma County (Calif.)', 'Mendocino County (Calif.)', 'Russian River Watershed (Calif.)']
      end

      it 'locn_geometry is a W,E,N,S envelope' do
        expect(iso_aardvark.metadata['locn_geometry'])
          .to eq 'ENVELOPE(-123.387866,-122.522658,39.399217,38.298024)'
      end

      it 'dcat_bbox' do
        expect(iso_aardvark.metadata['dcat_bbox']).to eq iso_aardvark.metadata['locn_geometry']
      end

      it 'does not crosswalk the larger work to pcdm_memberOf_sm or dct_isPartOf_sm' do
        expect(iso_object.metadata.at_xpath('//gmd:aggregationInfo', namespaces)).not_to be_nil
        expect(iso_aardvark.metadata).not_to have_key 'pcdm_memberOf_sm'
        expect(iso_aardvark.metadata).not_to have_key 'dct_isPartOf_sm'
      end

      it 'dct_rights_sm labels each source element' do
        expect(iso_aardvark.metadata['dct_rights_sm']).to eq [
          'Use limitation: No restrictions on access or use.',
          'Credit: Circuit Rider Productions and National Oceanic and Atmospheric Administration (2002). ' \
          'Hydrologic Sub-Area Boundaries: Russian River Watershed, California, 1999. Circuit Rider Productions.'
        ]
      end

      it 'dct_accessRights_s' do
        expect(iso_aardvark.metadata['dct_accessRights_s']).to eq 'Public'
      end

      it 'dct_format_s' do
        expect(iso_aardvark.metadata['dct_format_s']).to eq 'Shapefile'
      end

      it 'gbl_fileSize_s is in megabytes' do
        expect(iso_aardvark.metadata['gbl_fileSize_s']).to eq '0.3 MB'
      end

      it 'dct_references_s links the landing page and download' do
        expect(JSON.parse(iso_aardvark.metadata['dct_references_s'])).to eq(
          'http://schema.org/url' => 'http://purl.stanford.edu/bb338jh0716',
          'http://schema.org/downloadUrl' => 'http://purl.stanford.edu/bb338jh0716'
        )
      end

      it 'id is the provider and the last segment of the fileIdentifier' do
        expect(iso_aardvark.metadata['id']).to eq 'stanford-geospatial-center-bb338jh0716'
      end

      it 'dct_identifier_sm' do
        expect(iso_aardvark.metadata['dct_identifier_sm'])
          .to eq ['edu.stanford.purl:bb338jh0716', 'http://purl.stanford.edu/bb338jh0716']
      end

      it 'gbl_mdModified_dt is a full timestamp' do
        expect(iso_aardvark.metadata['gbl_mdModified_dt']).to eq '2014-10-08T00:00:00Z'
      end

      it 'gbl_mdVersion_s' do
        expect(iso_aardvark.metadata['gbl_mdVersion_s']).to eq 'Aardvark'
      end
    end

    describe 'field types' do
      it 'returns multivalued fields as arrays' do
        %w[dct_description_sm dct_language_sm dct_creator_sm dct_publisher_sm gbl_resourceClass_sm
           dct_subject_sm dcat_theme_sm dcat_keyword_sm dct_temporal_sm gbl_indexYear_im
           gbl_dateRange_drsim dct_spatial_sm dct_rights_sm dct_identifier_sm].each do |field|
          expect(iso_aardvark.metadata[field]).to be_an(Array), "expected #{field} to be an Array"
        end
      end

      it 'returns gbl_indexYear_im as integers' do
        expect(iso_aardvark.metadata['gbl_indexYear_im']).to all(be_an Integer)
      end

      it 'returns single-valued fields as strings' do
        %w[dct_title_s schema_provider_s dct_issued_s locn_geometry dcat_bbox dct_accessRights_s
           dct_format_s gbl_fileSize_s dct_references_s id gbl_mdModified_dt gbl_mdVersion_s].each do |field|
          expect(iso_aardvark.metadata[field]).to be_a(String), "expected #{field} to be a String"
        end
      end
    end

    describe 'with user-supplied fields' do
      it 'uses a supplied provider as the id prefix' do
        record = iso_object.to_aardvark('schema_provider_s' => 'Stanford')
        expect(record.metadata['schema_provider_s']).to eq 'Stanford'
        expect(record.metadata['id']).to eq 'stanford-bb338jh0716'
      end

      it 'uses a supplied id' do
        record = iso_object.to_aardvark('id' => 'stanford-bb338jh0716')
        expect(record.metadata['id']).to eq 'stanford-bb338jh0716'
      end

      it 'replaces the derived references with supplied ones' do
        references = { 'http://schema.org/url' => 'https://earthworks.stanford.edu/catalog/stanford-bb338jh0716' }.to_json
        record = iso_object.to_aardvark('dct_references_s' => references)
        expect(record.metadata['dct_references_s']).to eq references
      end

      it 'merges fields the source metadata cannot provide' do
        record = iso_object.to_aardvark('gbl_resourceType_sm' => ['Polygon data'])
        expect(record.metadata['gbl_resourceType_sm']).to eq ['Polygon data']
        expect(record).to be_valid
      end
    end

    describe 'with other ISO records' do
      describe 'an ArcGIS export of point data' do
        let(:record) { described_class.new(nyu_colleges_iso).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'gbl_resourceType_sm' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Point data']
        end

        it 'builds the id from the GUID fileIdentifier' do
          expect(record.metadata['id']).to eq 'newman-library-baruch-cuny-aa4b9423-91ff-402d-b901-3bb51ce1fc8f'
        end

        it 'finds the license written into the use limitation' do
          expect(record.metadata['dct_license_sm']).to eq ['http://creativecommons.org/licenses/by-nc-sa/4.0']
        end

        it 'treats licenseUnrestricted as Public' do
          expect(record.metadata['dct_accessRights_s']).to eq 'Public'
        end

        it 'labels the abstract, purpose and supplemental information' do
          expect(record.metadata['dct_description_sm'].map { |description| description.split(':').first })
            .to eq ['Abstract', 'Purpose', 'Supplemental information']
        end

        it 'escapes quotation marks in the abstract' do
          expect(record.metadata['dct_description_sm'].first).to include 'taken "as is"'
        end
      end

      describe 'a record without a fileIdentifier' do
        let(:record) { described_class.new(arizona_reservations_iso).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'builds the id from the dataSetURI' do
          expect(record.metadata['id']).to eq 'university-of-arizona-library-azu-geo-arizona-amerindianreservations-1970'
        end

        it 'treats a complex geometry as polygons' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Polygon data']
        end

        it 'ignores the temporal extents of lineage sources' do
          expect(record.metadata['dct_temporal_sm']).to eq ['1970']
          expect(record.metadata['gbl_indexYear_im']).to eq [1970]
        end

        it 'keeps only the date of a malformed date-time' do
          expect(record.metadata['dct_issued_s']).to eq '2007-01-01'
        end

        it 'keeps the time of the date stamp' do
          expect(record.metadata['gbl_mdModified_dt']).to eq '2017-08-16T16:30:09Z'
        end

        it 'dct_references_s' do
          expect(JSON.parse(record.metadata['dct_references_s']))
            .to eq('http://schema.org/url' => 'http://dx.doi.org/10.2458/azu_geo_arizona_amerindianreservations_1970')
        end
      end

      describe 'an ISO 19115-2 raster record' do
        let(:record) { described_class.new(arizona_topo_iso).to_aardvark }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'takes gbl_resourceClass_sm from the presentation form' do
          expect(record.metadata['gbl_resourceClass_sm']).to eq ['Imagery']
        end

        it 'gbl_resourceType_sm' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Raster data']
        end

        it 'reads the time period from either GML namespace' do
          expect(record.metadata['dct_temporal_sm']).to eq ['1970-1995']
          expect(record.metadata['gbl_dateRange_drsim']).to eq ['[1970 TO 1995]']
        end

        it 'indexes every year of the time period' do
          expect(record.metadata['gbl_indexYear_im']).to eq (1970..1995).to_a
        end

        it 'dct_format_s' do
          expect(record.metadata['dct_format_s']).to eq 'GeoTIFF'
        end
      end

      describe 'a record with services and downloads' do
        let(:record) { described_class.new(services_iso).to_aardvark }
        let(:references) { JSON.parse(record.metadata['dct_references_s']) }

        it 'is valid' do
          expect(record).to be_valid
        end

        it 'keeps unicode in the title' do
          expect(record.metadata['dct_title_s']).to eq 'Bike Lanes, Example City, 2019–2023'
        end

        it 'escapes quotation marks and backslashes and collapses line breaks' do
          expect(record.metadata['dct_description_sm'].first).to eq(
            'Abstract: Lanes marked "protected" are separated from traffic by a curb. ' \
            'Files follow the C:\\GIS\\bike naming convention.'
          )
        end

        it 'dct_alternative_sm' do
          expect(record.metadata['dct_alternative_sm']).to eq ['bike_lanes']
        end

        it 'drops the country from the language' do
          expect(record.metadata['dct_language_sm']).to eq ['eng']
        end

        it 'prefers people for dct_creator_sm' do
          expect(record.metadata['dct_creator_sm']).to eq ['Jane Q. Analyst', 'Example City Department of Transportation']
        end

        it 'prefers organizations for dct_publisher_sm' do
          expect(record.metadata['dct_publisher_sm']).to eq ['Example City Open Data', 'Example University Library']
        end

        it 'uses GBL Resource Class keywords' do
          expect(record.metadata['gbl_resourceClass_sm']).to eq ['Datasets', 'Web services']
        end

        it 'uses GBL Resource Type keywords' do
          expect(record.metadata['gbl_resourceType_sm']).to eq ['Line data']
        end

        it 'moves theme vocabulary out of dct_subject_sm' do
          expect(record.metadata['dct_subject_sm']).to eq ['Bicycle lanes', 'Cycling']
          expect(record.metadata['dcat_theme_sm']).to eq %w[Structure Transportation]
        end

        it 'dcat_keyword_sm' do
          expect(record.metadata['dcat_keyword_sm']).to eq ['bike_lanes_v2']
        end

        it 'describes an open-ended time period and a time instant' do
          expect(record.metadata['dct_temporal_sm']).to eq %w[2019-present 2021-05-17]
          expect(record.metadata['gbl_indexYear_im']).to eq [2019, 2021]
          expect(record.metadata).not_to have_key 'gbl_dateRange_drsim'
        end

        it 'keeps the precision of the publication date' do
          expect(record.metadata['dct_issued_s']).to eq '2023-06'
        end

        it 'combines the bounding boxes, skipping the excluded one' do
          expect(record.metadata['locn_geometry']).to eq 'ENVELOPE(-122.5,-122.1,37.9,37.6)'
        end

        it 'dct_rights_sm' do
          expect(record.metadata['dct_rights_sm'])
            .to eq ['Use limitation: CC BY 4.0', 'Other constraints: Available to Example University affiliates.']
        end

        it 'takes dct_license_sm from a linked license' do
          expect(record.metadata['dct_license_sm']).to eq ['https://creativecommons.org/licenses/by/4.0/']
        end

        it 'dct_accessRights_s' do
          expect(record.metadata['dct_accessRights_s']).to eq 'Restricted'
        end

        it 'normalizes the format name to an Aardvark format value' do
          expect(record.metadata['dct_format_s']).to eq 'Geodatabase'
        end

        it 'gbl_wxsIdentifier_s' do
          expect(record.metadata['gbl_wxsIdentifier_s']).to eq 'example:bike_lanes'
        end

        it 'links the landing page' do
          expect(references['http://schema.org/url']).to eq 'https://example.edu/catalog/bike-lanes'
        end

        it 'lists several downloads with labels' do
          expect(references['http://schema.org/downloadUrl']).to eq [
            { 'url' => 'https://data.example.edu/bike_lanes.zip', 'label' => 'Shapefile' },
            { 'url' => 'https://data.example.edu/bike_lanes.geojson', 'label' => 'GeoJSON' }
          ]
        end

        it 'links OGC service endpoints without their query strings' do
          expect(references['http://www.opengis.net/def/serviceType/ogc/wms']).to eq 'https://geo.example.edu/geoserver/wms'
          expect(references['http://www.opengis.net/def/serviceType/ogc/wfs']).to eq 'https://geo.example.edu/geoserver/wfs'
        end

        it 'links an Esri feature layer' do
          expect(references['urn:x-esri:serviceType:ArcGIS#FeatureLayer'])
            .to eq 'https://services.arcgis.com/abc123/arcgis/rest/services/Bike_Lanes/FeatureServer/0'
        end

        it 'builds the id from a URN fileIdentifier' do
          expect(record.metadata['id']).to eq 'example-university-library-3f1b8a52-6c0e-4d7a-9b1e-2a4c5d6e7f80'
        end

        it 'drops the time zone offset of the date stamp' do
          expect(record.metadata['gbl_mdModified_dt']).to eq '2024-03-05T14:22:10Z'
        end
      end
    end

    describe 'deriving controlled values' do
      it 'is Web services for a service record' do
        record = edited_record { |doc| scope_code(doc).set_attribute('codeListValue', 'service') }
        expect(record.metadata['gbl_resourceClass_sm']).to eq ['Web services']
      end

      it 'is Collections for a series record' do
        record = edited_record { |doc| scope_code(doc).set_attribute('codeListValue', 'series') }
        expect(record.metadata['gbl_resourceClass_sm']).to eq ['Collections']
      end

      it 'is Maps for a hardcopy map' do
        record = edited_record { |doc| presentation_form(doc).set_attribute('codeListValue', 'mapHardcopy') }
        expect(record.metadata['gbl_resourceClass_sm']).to eq ['Maps']
      end

      it 'is Other for an unrecognized scope' do
        record = edited_record { |doc| scope_code(doc).set_attribute('codeListValue', 'software') }
        expect(record.metadata['gbl_resourceClass_sm']).to eq ['Other']
      end

      it 'is Datasets when the record has no scope' do
        record = edited_record { |doc| doc.at_xpath('//gmd:hierarchyLevel', namespaces).remove }
        expect(record.metadata['gbl_resourceClass_sm']).to eq ['Datasets']
      end

      it 'is Line data for a curve geometry' do
        record = edited_record { |doc| geometry_code(doc).set_attribute('codeListValue', 'curve') }
        expect(record.metadata['gbl_resourceType_sm']).to eq ['Line data']
      end

      it 'is Polygon data for a surface geometry' do
        record = edited_record { |doc| geometry_code(doc).set_attribute('codeListValue', 'surface') }
        expect(record.metadata['gbl_resourceType_sm']).to eq ['Polygon data']
      end

      it 'is Table data for a text table' do
        record = edited_record do |doc|
          doc.at_xpath('//gmd:spatialRepresentationInfo', namespaces).remove
          doc.at_xpath('//gmd:MD_SpatialRepresentationTypeCode', namespaces).set_attribute('codeListValue', 'textTable')
        end
        expect(record.metadata['gbl_resourceType_sm']).to eq ['Table data']
      end

      it 'is Restricted when access needs a license' do
        record = edited_record do |doc|
          doc.at_xpath('//gmd:MD_LegalConstraints', namespaces).add_child(<<~XML)
            <accessConstraints>
              <MD_RestrictionCode codeListValue="license">license</MD_RestrictionCode>
            </accessConstraints>
          XML
        end
        expect(record.metadata['dct_accessRights_s']).to eq 'Restricted'
      end

      it 'is Restricted when other constraints say so' do
        record = edited_record { |doc| add_access_constraint(doc, 'Access is restricted to Stanford users.') }
        expect(record.metadata['dct_accessRights_s']).to eq 'Restricted'
      end

      it 'is Public when other constraints say unrestricted' do
        record = edited_record { |doc| add_access_constraint(doc, 'Unrestricted access.') }
        expect(record.metadata['dct_rights_sm']).to include 'Other constraints: Unrestricted access.'
        expect(record.metadata['dct_accessRights_s']).to eq 'Public'
      end

      it 'is Restricted for a security classification' do
        record = edited_record do |doc|
          doc.at_xpath('//gmd:resourceConstraints', namespaces).add_next_sibling(<<~XML)
            <resourceConstraints>
              <MD_SecurityConstraints>
                <classification>
                  <MD_ClassificationCode codeListValue="confidential">confidential</MD_ClassificationCode>
                </classification>
              </MD_SecurityConstraints>
            </resourceConstraints>
          XML
        end
        expect(record.metadata['dct_accessRights_s']).to eq 'Restricted'
      end

      it 'pads a date stamp that is only a year' do
        record = edited_record { |doc| doc.at_xpath('//gmd:dateStamp/gco:Date', namespaces).content = '2014' }
        expect(record.metadata['gbl_mdModified_dt']).to eq '2014-01-01T00:00:00Z'
      end

      it 'omits locn_geometry when there is no bounding box, so the record is invalid' do
        record = edited_record { |doc| doc.at_xpath('//gmd:EX_GeographicBoundingBox', namespaces).remove }
        expect(record.metadata).not_to have_key 'locn_geometry'
        expect(record).not_to be_valid
      end
    end
  end

  describe '#to_html' do
    it 'creates a transformation of the metadata as a String' do
      expect(iso_object.to_html).to be_an String
    end
  end

  def namespaces
    { 'gmd' => 'http://www.isotc211.org/2005/gmd', 'gco' => 'http://www.isotc211.org/2005/gco' }
  end

  ##
  # Converts the Stanford fixture after yielding it to the caller to change
  def edited_record
    doc = Nokogiri::XML(stanford_iso)
    yield doc
    described_class.new(doc.to_xml).to_aardvark
  end

  def scope_code(doc)
    doc.at_xpath('//gmd:hierarchyLevel/gmd:MD_ScopeCode', namespaces)
  end

  def presentation_form(doc)
    doc.at_xpath('//gmd:presentationForm/gmd:CI_PresentationFormCode', namespaces)
  end

  def geometry_code(doc)
    doc.at_xpath('//gmd:MD_GeometricObjectTypeCode', namespaces)
  end

  # The Stanford fixture is in the default gmd namespace, so the added elements are too
  def add_access_constraint(doc, text)
    doc.at_xpath('//gmd:MD_LegalConstraints', namespaces).add_child(<<~XML)
      <accessConstraints>
        <MD_RestrictionCode codeListValue="otherRestrictions">otherRestrictions</MD_RestrictionCode>
      </accessConstraints>
      <otherConstraints>
        <gco:CharacterString>#{text}</gco:CharacterString>
      </otherConstraints>
    XML
  end
end
