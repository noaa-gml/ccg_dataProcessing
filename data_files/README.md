An archive of CCGG pre-processed measurement data files for tank calibrations, instrument response curves, insitu and flask air analyses is available here:

https://doi.org/10.15138/4GJN-EM74

## Files Provided

- `ccg_preprocessed_data_files_[release date].tar.gz` — the data archive
- `ccg_preprocessed_data_files_[release date].tar.gz.sha256` — SHA-256 checksum of the archive

The checksum file has also been stored in the NOAA GML GitHub repository:

https://github.com/noaa-gml/ccg_dataProcessing/data_files/ccg_preprocessed_data_files_[release date].tar.gz.sha256

Both checksum files are identical and can be used to validate copies of the archive.
If retrieving the archive from an alternate repository, verify that the checksum file matches
the GitHub version.

---

## Verifying the Integrity of This Archive

The archive is provided with a SHA-256 checksum so you can verify that it hasn’t been altered or corrupted.  This allows you to establish that the archive is what was published by GML.

---


## Verify the SHA-256 Checksum

Use this command in a terminal to ensure the archive’s integrity:

linux bash:

sha256sum -c ccg_preprocessed_data_files_[release date].tar.gz.sha256

OSX terminal:

shasum -a 256 -c ccg_preprocessed_data_files_[release date].tar.gz.sha256


If it returns OK, then the file is valid and unaltered.

