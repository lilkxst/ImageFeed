//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Артём Костянко on 25.07.23.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testProfileViewControllerCallsViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    private let profileService = ProfileServiceStub.shared
    var viewDidLoadCalled: Bool = false
    var didUpdateProfileCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateProfileDetails() {
        guard let view = self.view else {return}
        view.descriptionLabel.text = profileService.profile?.bio ?? ""
        view.linkLabel.text = profileService.profile?.loginName
        view.nameLabel.text = profileService.profile?.name ?? ""
        didUpdateProfileCalled = true
        
    }
    
    func updateAvatar() {
    }
    
    func logOut() {
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    static let shared = ProfileServiceStub()
    private(set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<ImageFeed.Profile, Error>) -> ()) {
        self.profile = Profile(username: "UserName",
                               name: "Name",
                               loginName: "@Login",
                               bio: "someBio")
    }
}
