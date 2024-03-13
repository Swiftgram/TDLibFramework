# CocoaPods & Flutter

TDLibFramework is distributed only via SPM. You will need some additional setup to include this framework to your Flutter Swift plugin or CocoaPods project.

1. Patch `Podfile` to support SPM and change `TARGET` with Your Swift Plugin name

```ruby
SPM_DEPS = [
  {
    targets: ["TARGET"], 
    spec: {
      url: "https://github.com/Swiftgram/TDLibFramework",
      requirement: {
        kind: "upToNextMajorVersion",
        # Grab latest version from https://github.com/Swiftgram/TDLibFramework/releases
        minimumVersion: "1.8.26-b41f3219"
      },
      product_name: "TDLibFramework"
    }
  }
]

# Patching support for SPM deps https://github.com/CocoaPods/CocoaPods/issues/10049#issuecomment-819480131
def add_spm_to_target(project, target_name, url, requirement, product_name)
  project.targets.each do |target|
    if target.name == target_name
      pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
      pkg.repositoryURL = url
      pkg.requirement = requirement
      ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
      ref.package = pkg
      ref.product_name = product_name
      target.package_product_dependencies << ref
      project.root_object.package_references << pkg
    end
  end

  project.save
end
```

2. Append `post_install` script with SPM deps install

```ruby
post_install do |installer|
  ### Flutter only
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
  ###

  # Add SPM deps
  puts "Including SPM dependencies"
  SPM_DEPS.each do |spm_dep|
    spm_dep[:targets].each do |target|
      add_spm_to_target(
        installer.pods_project,
        target,
        spm_dep[:spec][:url],
        spm_dep[:spec][:requirement],
        spm_dep[:spec][:product_name]
      )
    end
  end
end
```
