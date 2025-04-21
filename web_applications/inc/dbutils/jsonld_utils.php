<?php
/*Utilities for generating json+ld content.
*/
function jsonld_processObspack($zipFilePath, $outputDirectory='/webdata/ccgg/ObsPack/products/jsonld') {
    /*Create json ld metadata content for single obspack package and write to passed directory.*/

    // Ensure the output directory exists
    if (!is_dir($outputDirectory)) { mkdir($outputDirectory, 0755, true);  }
    $fileName = basename($zipFilePath);
    $namePart = preg_replace('/\.(nc|txt)?\.(tar\.gz|gz|zip)$/', '', $fileName);#the package

    // Open the zip file
    $zip = new ZipArchive();
    if ($zip->open($zipFilePath) !== true) {throw new Exception("Unable to open zip file: $zipFilePath");}

    // We'll just process the nc files
    $ncFiles = [];
    for ($i = 0; $i < $zip->numFiles; $i++) {
        $file = $zip->getNameIndex($i);
        if (strpos($file, '/data/nc/') !== false && pathinfo($file, PATHINFO_EXTENSION) === 'nc') {
            $ncFiles[] = $file;
        }
    }

    if (empty($ncFiles)) {
        throw new Exception("No .nc files found in the /data/nc/ directory.");
    }

    //Search for included download types and list them all
    $dist=jsonld_createObspackDistributions($zipFilePath);

    //Create the parentDataset obj
    $parentDataset = [
        '@context' => 'https://schema.org/',
        '@type' => 'Dataset',
        'publisher'=>["@id"=> "gml.noaa.gov","@type"=> "Organization","logo"=> "https://gml.noaa.gov/images/noaa_small.webp","name"=> "NOAA GML","url"=> "https://gml.noaa.gov"],
        //'provider'=>["@id"=> "gml.noaa.gov","@type"=> "Organization","logo"=> "https://gml.noaa.gov/images/noaa_small.webp","name"=> "NOAA GML Obspack","url"=> "https://gml.noaa.gov/ccgg/obspack/"],
        'creator'=>["@id"=> "gml.noaa.gov","@type"=> "Organization","logo"=> "https://gml.noaa.gov/images/noaa_small.webp","name"=> "NOAA GML Obspack","url"=> "https://gml.noaa.gov/ccgg/obspack/"],
        'inLanguage'=>jsonld_createInLanguage('English'),
        'includedInDataCatalog'=>jsonld_createIncludedInDataCatalog('NOAA GML Obspack','https://gml.noaa.gov/ccgg/obspack/our_products.php'),
        'distribution'=>$dist,
        "keywords"=> ["Earth Science > Atmosphere > Atmospheric Chemistry > Carbon and Hydrocarbon compounds",
            "NOAA GLOBAL MONITORING", "OBSPACK"],
        'hasPart' => [],

    ];

    //Create datasets for each included file, use the first one to get the obspack details (name, doi...)
    $parentID='';
    foreach ($ncFiles as $index => $ncFile) {
        #if($index>1)continue;//just for testing

        // Extract file to a temporary location and pull header
        $tempNcFile = sys_get_temp_dir() . '/' . basename($ncFile);
        file_put_contents($tempNcFile, $zip->getFromName($ncFile));
        #cmd for omi: $command = "/ccg/src/crontabs/pyshell.bsh ncdump -h " . escapeshellarg($tempNcFile) . " 2>&1";
        $command = "ncdump -h " . escapeshellarg($tempNcFile) . " 2>&1";
        $header = shell_exec($command);
        if ($header === null) {
            throw new Exception("Failed to read header for file: $tempNcFile");
        }
        //Make assoc array from header
        $harr=jsonld_parseObspackHeaderToArray($header);

        // Populate parent dataset metadata from the first file (index 0)
        if ($index === 0) {

            if(isset($harr['obspack_identifier_link']))$parentID=$harr['obspack_identifier_link'];#DOI
            else $parentID=$namePart;#package name

            $parentDataset['@id'] = $parentID;
            $parentDataset['name'] = isset($harr['obspack_name'])? $harr['obspack_name'] : basename($zipFilePath);
            $parentDataset['description'] = isset($harr['obspack_description'])? $harr['obspack_description'] :'';
            $parentDataset['datePublished'] = isset($harr['obspack_creation_date'])? $harr['obspack_creation_date'] :'';
            $parentDataset['url'] =isset($harr['obspack_identifier_link'])? $harr['obspack_identifier_link'] :'';
            $parentDataset['citation'] = isset($harr['obspack_citation'])? $harr['obspack_citation'] :'';
            $parentDataset['license'] = [
                '@type' => 'CreativeWork',
                'url' => isset($harr['obspack_usage_policy'])? $harr['obspack_usage_policy'] :'',
            ];
            if(isset($harr['dataset_parameter'])){
                $parentDataset['variableMeasured']=[
                    "@context"=>"https://schema.org/",
                    "@type"=> "StatisticalVariable",
                    "@id"=> $harr['dataset_parameter'],
                    "name"=> $harr['dataset_parameter'].' '.$harr["value:comment"],
                    "measuredProperty"=> ["@id"=> $harr["value:long_name"]],

                ];
                if($harr['dataset_parameter']=='co2')$parentDataset['keywords'][]="ATMOSPHERIC CARBON DIOXIDE";
                if($harr['dataset_parameter']=='ch4')$parentDataset['keywords'][]="Atmospheric Methane";
                if($harr['dataset_parameter']=='sf6')$parentDataset['keywords'][]="Atmospheric Sulfur Hexafluoride";
                if($harr['dataset_parameter']=='co')$parentDataset['keywords'][]="Atmospheric Carbon Monoxide";
                if($harr['dataset_parameter']=='n2o')$parentDataset['keywords'][]="Atmospheric Nitrous Oxide";
            }
        }
        //Create a subdataset for file
        $childDataset = jsonld_createJsonLdFromObspackNcHeader($harr,$parentID);

        // Add the entire child dataset to parent's hasPart
        $parentDataset['hasPart'][] = $childDataset;

        // Merge spatial coverage into parent (putting this info into the child dataset)
        ##if (isset($childDataset['spatialCoverage'])) {
        ##    $parentDataset['spatialCoverage'][] = $childDataset['spatialCoverage'];
        ##}

        // Clean up temporary file
        unlink($tempNcFile);


    }

    // Consolidate spatial coverage into parent dataset (remove duplicates)
    ##$parentDataset['spatialCoverage'] = array_values(array_unique($parentDataset['spatialCoverage'], SORT_REGULAR));

    // Save parent dataset to output directory
    $parentOutputPath = $outputDirectory . "/".$namePart.".jsonld";
    file_put_contents($parentOutputPath, '<script type="application/ld+json">'.json_encode($parentDataset, JSON_UNESCAPED_SLASHES).'</script>');//Compact format

    $zip->close();
    echo json_encode($parentDataset, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);//Output to screen to verify
    echo "Processing complete. JSON-LD content saved to $parentOutputPath.\n";
}




function jsonld_parseObspackHeaderToArray($header) {
    /*Read in header content from netcdf obspack file and parse into assoc array*/
    $parsed = [];
    $lines = explode("\n", $header); // Split header into lines

    foreach ($lines as $line) {
        // Remove leading/trailing whitespace
        $line = trim($line);

        // Only process lines contain an = (note this leaves off variables, but includes var attributes)
        if (strpos($line, '=') !== false) {
            // Split the line at the `=` sign
            $parts = explode('=', $line, 2);

            if (count($parts) === 2) {
                // Extract the key and value
                $key = trim($parts[0], ': '); // Remove ':' and extra spaces
                $value = trim($parts[1], ' ;"'); // Remove ';', spaces, and quotes

                // Attempt to convert the value to a number if possible
                if (is_numeric($value)) {
                    $value += 0; // Convert to int or float
                }

                $parsed[$key] = $value;
                #var_dump($parsed['site_code']);exit();
            }
        }
    }
    return $parsed;
}


function jsonld_createJsonLdFromObspackNcHeader($header,$parentID) {
    #create a dataset for individual files in obspack
    $a= ['@context' => 'https://schema.org/','@type' => 'Dataset'];
    if(isset($header['dataset_name']))$a['name']=$header['dataset_name'];
    #if(isset($header['dataset_description']))$a['description']=$header['dataset_description']; //This was large and duplicated for most files, so not helpful
    $country=(isset($header['site_country']))?$header['site_country']:"";
    //Generate a description of the contents.  Assumes some of the fields are present.
    $a['description']=$header['dataset_parameter'].' '.$header['value:comment'].', '.$header['dataset_selection'].', '.$header['site_name'].', '.$country.' ('.$header['site_code'].')';
    $a['isPartOf']=$parentID;//This links it back to the parent obspack
    $a['@id']=$parentID."?dataset=".$header['dataset_name'];//unique id for dataset.  Use php parameter syntax incase we need to do something with it in the future.
    $providers = [];
    /*This produced too much content for obspacks, so just doing 1st lab for now
    foreach ($header as $key => $value) {
        if (preg_match('/^provider_(\d+)_name$/', $key, $matches)) {
            $number = (int)$matches[1];
            $p = ["@type"=> "Person","name"=> $value,];
            if(isset($header['provider_'.$number.'_affiliation']))$p['affiliation']=$header['provider_'.$number.'_affiliation'];
            $providers[]=$p;
        }
        if (preg_match('/^lab_(\d)+_name$/', $key, $matches)) {
            $number = (int)$matches[1];
            $p = ["@type"=> "Organization","name"=> $value,];
            if(isset($header['lab_'.$number.'_url']))$p['url']=$header['lab_'.$number.'_url'];
            if(isset($header['lab_'.$number.'_abbr']))$p['alternateName']=$header['lab_'.$number.'_abbr'];
            if(isset($header['lab_'.$number.'_logo']))$p['logo']=$header['lab_'.$number.'_logo'];
            $providers[]=$p;
        }
    }*/
    if(isset($header['lab_1_name'])){
        $p = ["@type"=> "Organization","name"=> $header['lab_1_name']];
        if(isset($header['lab_1_url']))$p['url']=$header['lab_1_url'];
        if(isset($header['lab_1_abbr']))$p['alternateName']=$header['lab_1_abbr'];
        $providers[]=$p;
    }

    if($providers)$a['provider']=$providers;
    //Add in coords
    if(isset($header['site_latitude']) && $header['site_latitude']!='-1.e+34'){
        $elevation=(isset($header['site_elevation']))?$header['site_elevation']:null;
        $a['spatialCoverage']=jsonld_createSpatialCoverage($header['site_latitude'] ,$header['site_longitude'],$elevation);
    }
    //And time span
    $a['temporalCoverage']=jsonld_createTemporalCoverage($header['dataset_start_date'] ,$header['dataset_stop_date']);

    return $a;
}
//Here are some generic builder functions.  I ended up not using the higher level ones (gen dataset, wrap with script tags),
//because it was easier to just build it directly, but did use some of the others like temporal/spatial coverage blocks.
//The ones not used (gen dataset) may need to be updated if you try to use them.
//jwm. 2024.12.9
function jsonld_createJSONLD($data){
    $jsonLD=jsonld_generateDataset($data);
    return '<script type="application/ld+json">'.$jsonLD.'</script>';
}
function jsonld_generateDataset(array $data) {
/**
 * Generate JSON-LD for a Dataset schema.org object.
 *
 * This function creates a JSON-LD string representation of a Dataset using the Schema.org vocabulary.
 *
 * ### Required Fields:
 * - `@context`: Always "https://schema.org".
 * - `@type`: Always "Dataset".
 * - `name`: (string) The name of the dataset.
 * - `description`: (string) A brief description of the dataset.
 * - `url`: (string) The URL of the dataset or its landing page.
 * - `creator`: (array/object) Information about the creator (Organization or Person).
 *
 * ### Optional Fields:
 * - `keywords`: (array) Descriptive keywords (e.g., ["climate", "temperature"]).
 * - `license`: (string) A URL to the dataset's license.
 * - `version`: (string) The version of the dataset.
 * - `datePublished`: (string) Publication date in ISO 8601 format (e.g., "2024-01-01").
 * - `dateModified`: (string) Last modified date in ISO 8601 format (e.g., "2024-12-01").
 * - `identifier`: (string) A unique identifier (e.g., DOI, URI).
 * - `citation`: (string/array) References to be cited (e.g., ["Smith et al. 2023"]).
 * - `contributor`: (array) Contributors (array of Organization or Person objects).
 * - `distribution`: (array) How the dataset can be accessed (e.g., file URLs).
 *   Example:
 *   [
 *       {
 *           "@type": "DataDownload",
 *           "contentUrl": "https://example.com/file.csv",
 *           "fileFormat": "text/csv"
 *       }
 *   ]
 * - `spatialCoverage`: (object) Geographic coverage (e.g., coordinates).
 *   Example:
 *   {
 *       "@type": "Place",
 *       "geo": {
 *           "@type": "GeoCoordinates",
 *           "latitude": 40.7128,
 *           "longitude": -74.0060
 *       }
 *   }
 * - `temporalCoverage`: (string) Time range in ISO 8601 format (e.g., "2020-01-01/2024-12-31").
 * - `isAccessibleForFree`: (boolean) Whether the dataset is free to access.
 * - `funding`: (object) Funding source details.
 *
 * ### Usage:
 * Pass an associative array with the required and optional fields as input.
 * Returns a JSON-LD string that can be embedded into a webpage.
 *
 * @param array $data Associative array containing required and optional Dataset fields.
 * @return string JSON-LD string.
 * @throws InvalidArgumentException If required fields are missing.
 */

    // Define required fields
    $requiredFields = ['name', 'description', 'url', 'creator'];

    // Validate required fields
    foreach ($requiredFields as $field) {
        if (!isset($data[$field])) {
            throw new InvalidArgumentException("Missing required field: $field");
        }
    }

    // Start building the JSON-LD structure
    $jsonLD = [
        '@context' => 'https://schema.org',
        '@type' => 'Dataset',
        'name' => $data['name'],
        'description' => $data['description'],
        'url' => $data['url'],
        'creator' => $data['creator'],
    ];

    // Add optional fields if they exist
    $optionalFields = [
        'keywords', 'license', 'version', 'datePublished', 'dateModified',
        'identifier', 'citation', 'contributor', 'distribution',
        'spatialCoverage', 'temporalCoverage', 'isAccessibleForFree', 'funding'
    ];

    foreach ($optionalFields as $field) {
        if (isset($data[$field])) {
            $jsonLD[$field] = $data[$field];
        }
    }

    // Return the JSON-LD as a formatted string
    return json_encode($jsonLD, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);

}






function jsonld_createSpatialCoverage($latitude, $longitude,  $elevation=null, $name = null, $description = null,$type = 'Place', $geoType = 'GeoCoordinates') {
    /**
     * Create a spatialCoverage object for a Dataset.
     *
     * Inputs:
     * - `latitude`: (float) Latitude of the location.
     * - `longitude`: (float) Longitude of the location.
     elevation in meters
     * - `type`: (string, optional) Type of the spatialCoverage object (default: "Place").
     * - `geoType`: (string, optional) Type of geo object (default: "GeoCoordinates").
     * - `name`: (string, optional) Name of the location.
     * - `description`: (string, optional) Description of the location.
     *
     * Example usage:
     * createSpatialCoverage(40.7128, -74.0060, name: "New York City", description: "A major city in the USA.");
     */

    #if (!is_numeric($latitude) || !is_numeric($longitude)) {
     #   throw new InvalidArgumentException("Latitude and longitude must be numeric values.");
    #}

    // Build the spatialCoverage object
    $elevation=($elevation)?"$elevation m":'';
    $spatialCoverage = [
        '@type' => $type,
        'geo' => [
            '@type' => $geoType,
            'latitude' => $latitude,
            'longitude' => $longitude,
            'elevation' =>$elevation,
        ]
    ];

    // Add optional fields if provided
    if ($name) {
        $spatialCoverage['name'] = $name;
    }
    if ($description) {
        $spatialCoverage['description'] = $description;
    }

    return $spatialCoverage;
}

function jsonld_createCreator($name, $type = 'Organization', $url = null,$logo='') {
    /**
     * Create a creator object for a Dataset.
     *
     * Inputs:
     * - `name`: (string) Name of the creator (Organization or Person).
     * - `type`: (string, optional) Type of the creator (default: "Organization").
     * - `url`: (string, optional) URL of the creator's website.
     * - logo : (string, optional) url of logo
     * Example usage:
     * createCreator("NOAA", "Organization", "https://noaa.gov");
     */

    if (empty($name)) {
        throw new InvalidArgumentException("Name is required for the creator.");
    }

    $creator = [
        '@type' => $type,
        'name' => $name,
    ];

    if($url)$creator['url'] = $url;
    if($logo)$creator['logo']=$logo;

    return $creator;
}

function jsonld_createIncludedInDataCatalog($name, $url = null) {
    /**
     * Create an includedInDataCatalog object for a Dataset.
     *
     * Inputs:
     * - `name`: (string) Name of the data catalog.
     * - `url`: (string, optional) URL of the data catalog.
     *
     * Example usage:
     * createIncludedInDataCatalog("National Data Catalog", "https://catalog.example.com");
     */

    if (empty($name)) {
        throw new InvalidArgumentException("Name is required for the data catalog.");
    }

    $dataCatalog = ['@type' => 'DataCatalog','name' => $name,];

    if ($url) {
        $dataCatalog['url'] = $url;
    }

    return $dataCatalog;
}

function jsonld_createInLanguage($languageName) {
    /**
     * Create an inLanguage object for a Dataset.
     *
     * Inputs:
     * - `languageName`: (string, optional) The full name of the language (e.g., "English").
     *
     * Example usage:
     * createInLanguage("en", "English");
     */
    $language = ['@type' => 'Language', 'name' => $languageName];

    return $language;
}

function jsonld_createTemporalCoverage($startDate, $endDate = null) {
    /* Create a temporalCoverage string for a Dataset.
     * - `startDate`: (string) Start date in ISO 8601 format (e.g., "2020-01-01").
     * - `endDate`: (string, optional) End date in ISO 8601 format (e.g., "2024-12-31").
     *
     * Example usage:
     * createTemporalCoverage("2020-01-01", "2024-12-31");
     */
    return $endDate ? "$startDate/$endDate" : $startDate;
}
function jsonld_createDistribution($encodingFormat,$contentUrl,$contentSize = null,
    $name = null,$description = null,$type = 'DataDownload'){
    /**
 * Generate a distribution array for a Dataset.
 *
 * This function creates an array representing a single distribution object for the `distribution` field
 * in a Schema.org Dataset. The object describes how the dataset can be accessed or downloaded.
 *
 * ### Inputs:
 * - `type`: (string, optional) Type of the distribution. Default is "DataDownload".
 * - `encodingFormat`: (string, required) File format (e.g., "text/csv", "application/json").
 * - `contentSize`: (string, optional) Size of the file (e.g., "15MB").
 * - `contentUrl`: (string, required) URL where the file can be accessed.
 * - `name`: (string, optional) A name or title for the distribution.
 * - `description`: (string, optional) A brief description of the distribution.
 *
 * ### Output:
 * Returns an array representing the distribution object.

 */

    // Build the distribution array
    $distribution = [
        '@type' => $type,
        'encodingFormat' => $encodingFormat,
        'contentUrl' => $contentUrl,
    ];

    // Add optional fields if provided
    if ($contentSize) {
        $distribution['contentSize'] = $contentSize;
    }
    if ($name) {
        $distribution['name'] = $name;
    }
    if ($description) {
        $distribution['description'] = $description;
    }

    return $distribution;
}

function jsonld_createObspackDistributions($filePath) {
    $directory = dirname($filePath);
    $fileName = basename($filePath);
    $namePart = preg_replace('/\.(nc|txt)?\.(tar\.gz|gz|zip)$/', '', $fileName);
    $contentUrl="https://gml.noaa.gov/ccgg/obspack/data.php?id=".$namePart;

    // Supported file suffixes and their encoding formats
    $encodingFormats = [
        '.nc.tar.gz' => 'application/x-tar+gzip',
        '.txt.tar.gz' => 'application/x-tar+gzip',
        '.nc.zip' => 'application/zip',
        '.txt.gz' => 'application/gzip',
        '.txt.zip' => 'application/zip',
        '.zip' => 'application/zip',
        '.gz' => 'application/gzip',
    ];

    $distributions = [];
    if ($handle = opendir($directory)) {
        while (false !== ($entry = readdir($handle))) {
            // Match files with the same name part
            foreach ($encodingFormats as $suffix => $format) {
                if (preg_match('/^' . preg_quote($namePart, '/') . preg_quote($suffix, '/') . '$/', $entry)) {
                    $filePath = $directory . DIRECTORY_SEPARATOR . $entry;
                    $fileSize = filesize($filePath)." B";

                    // Detect content type if compressed
                    $contentDescription = null;
                    if (strpos($suffix, '.gz') !== false || strpos($suffix, '.zip') !== false) {
                        $contentDescription = strpos($entry, '.txt') !== false ? 'This archive contains text files.' :
                                              (strpos($entry, '.nc') !== false ? 'This archive contains NetCDF4 files.' : null);
                    }
                    $distribution=jsonld_createDistribution($format,$contentUrl,$fileSize,
    $entry,$contentDescription,'DataDownload');


                    $distributions[] = $distribution;
                }
            }
        }
        closedir($handle);
    }

    return $distributions;
}
function jsonld_createInDataCatalog($name){
    /*Creates the includedInDataCatalog section*/
     return ["@type"=>"DataCatalog","name"=>$name];
}
// Example usage: (may not be up to date!)
/*try {
    $tempCoverage=jsonld_createTemporalCoverage("2020-01-01", "2024-12-31");
    $lang=jsonld_createInLanguage("English");
    $inCat=jsonld_createIncludedInDataCatalog("National Data Catalog", "https://catalog.example.com");
    $creator=jsonld_createCreator("NOAA", "Organization", "https://noaa.gov");
    $dist1 = jsonld_createDistribution('text/csv','https://example.com/data.csv','15MB','Sample Data CSV','A CSV file containing sample data.');
    $dist2=jsonld_createDistribution('NetCDF4','https://gml.noaa.gov/aftp/data/trace_gases/co2/flask/surface/nc/co2_alt_surface-flask_1_ccgg_event.nc','456 kB','ALT surface Flask');
    $dist=[$dist1,$dist2];
    $cat=jsonld_createInDataCatalog('gml.noaa.gov/ccgg/obspack/data.php');
    $spatialCoverage=jsonld_createSpatialCoverage(40.7128, -74.0060, "New York City", "A major city in the USA.");
    $dataset = [
        'name' => 'Sample Dataset',
        'description' => 'A description of the sample dataset.',
        'url' => 'https://example.com/dataset',
        'creator' => [
            '@type' => 'Organization',
            'name' => 'Example Organization',
        ],
        'keywords' => ['sample', 'dataset', 'example'],
        'datePublished' => '2024-12-01',
        'license' => 'https://creativecommons.org/licenses/by/4.0/',
        'distribution'=>$dist,
        'spatialCoverage'=>$spatialCoverage,
        'creator'=>$creator,
        'includedInDataCatalog'=>$inCat,
        'inLanguage'=>$lang,
        'temporalCoverage'=>$tempCoverage
    ];

    $jsonLD = jsonld_generateDataset($dataset);
    echo $jsonLD;
} catch (InvalidArgumentException $e) {
    echo "Error: " . $e->getMessage();
}

*/

?>
