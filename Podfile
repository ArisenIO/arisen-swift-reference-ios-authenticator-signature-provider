using_local_pods = ENV['USE_LOCAL_PODS'] == 'true' || false

platform :ios, '11.0'

# ignore all warnings from all pods
inhibit_all_warnings!

if using_local_pods
  # Pull pods from sibling directories if using local pods
  target 'ArisenSwiftReferenceAuthenticatorSignatureProvider' do
    use_frameworks!

    pod 'ArisenSwift', :path => '../arisen-swift'
    pod 'SwiftLint'

    target 'ArisenSwiftReferenceAuthenticatorSignatureProviderTests' do
      inherit! :search_paths
      pod 'ArisenSwift', :path => '../arisen-swift'
    end
  end
else
  # Pull pods from sources above if not using local pods
  target 'ArisenSwiftReferenceAuthenticatorSignatureProvider' do
    use_frameworks!

    pod 'ArisenSwift', '~> 0.1.1'
    pod 'SwiftLint'

    target 'ArisenSwiftReferenceAuthenticatorSignatureProviderTests' do
      inherit! :search_paths
      pod 'ArisenSwift', '~> 0.1.1'
    end
  end
end
