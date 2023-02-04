# Changelog

## [0.4.0] - 2023-02-04

### Added

- Added `OnEnd` and `OnEndArgumentList` parameters to `Enter-RSSession`

### Changed

- Changed `ArgumentList` parameter name to `OnStartArgumentList`

### Deprecated

- `ArgumentList` parameter is now an alias to `OnStartArgumentList` and will be removed in the next release

## [0.3.0] - 2022-11-13

### Added

- Added Linux support
- Added `ShowProcessId` parameter to `Enter-RSSession`

## [0.2.0] - 2022-11-08

### Fixed

- Fixed an issue where RSSession failed to load RestartableSession module at `Enter-RSSession` 

## [0.1.0] - 2022-11-08

### Added

- Added `Enter-RSSession`
- Added `Exit-RSSession`
- Added `Restart-RSSession`
- Added `Start-RSRestartFileWatcher`
- Added `Stop-RSRestartFileWatcher`