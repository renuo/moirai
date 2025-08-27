## Unreleased

## 0.4.6

* Allows to access `current_user` and other controller available methods in the `enable_inline_editing` function. ([@coorasse][])
* Improved project setup.  ([@simon-isler][])
* Various bug fixes

## 0.4.5

* Fixes issue when inline editing is disabled. ([@nicogaldamez][])

## 0.4.4

* Allow to configure the root_path of moirai

## 0.4.3

* Do not initialize moirai if we don't have a database connection. ([@coorasse][])

## 0.4.2

* Fix bug when the params is defined but is `nil`. ([@coorasse][])

## 0.4.1

* Fix bug when the string is not a string, but a boolean. ([@coorasse][])

## 0.4.0 - Breaking Changes ⚠️

* Inline editing is now disabled by default. To enable it, specify the following in `application.rb`:

```ruby
config.moirai.enable_inline_editing = ->(params:) { your_options_here }
```

move in here the conditions you had previously defined in the helper.

* Moirai now works also in emails. That's why we have a breaking change. ([@coorasse][])

## 0.3.1

* Fixes a problem when running a rake command and no database exists yet using postgres. ([@coorasse][])

## 0.3.0

* Added a method `I18n.translate_without_moirai` ([@oliveranthony17][])
* Simplified stimulus setup ([@coorasse][])
* Fixed some setup issues in test environments ([@oliveranthony17][])
* Show original translation when deleting the whole inline editing content. ([@CuddlyBunion341][])

* Support for html translations ([@CuddlyBunion341][])
=======
## 0.2.0

* Support for strings coming from gems ([@coorasse][])
* Support for new strings (not yet translated) ([@coorasse][])

## 0.1.1

* Review Stimulus controller ([@coorasse][])

## 0.1.0 

* Gem structure created ([@oliveranthony17][])
* Database tables created ([@oliveranthony17][])
* Pull request creation ([@oliveranthony17][])
* Dummy app for tests ([@coorasse][])
* CRUD for translations ([@CuddlyBunion341][])
* Inline editing ([@CuddlyBunion341][])

[@coorasse]: https://github.com/coorasse

[@oliveranthony17]: https://github.com/oliveranthony17

[@CuddlyBunion341]: https://github.com/CuddlyBunion341

[@nicogaldamez]: https://github.com/nicogaldamez

[@simon-isler]:  https://github.com/simon-isler
