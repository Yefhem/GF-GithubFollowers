//
//  FollowersViewModel.swift
//  GithubFollowers
//
//  Created by Cem Nisan on 21.04.2022.
//

import GFNetwork

final class FollowersViewModel: FollowersViewModelProtocol {
    
    var username: String
    var isSearching: Bool = false
    private var followers: [Follower] = []
    private var filteredFollowers: [Follower] = []
    
    weak var delegate: FollowersViewModelDelegate?
    private var service: FollowerServiceable
    
    init(service: FollowerServiceable,
         username: String) {
        self.service  = service
        self.username = username
    }
}

// MARK: - Loader
extension FollowersViewModel {
    
    func loadFollowers(pageNumber: Int) async {
        notify(.isLoading(true))
        let result = await service.getUserFollowers(with: username)
        notify(.isLoading(false))
        
        followersResults(results: result)
    }
}

// MARK: - Results
extension FollowersViewModel {
    
    private func followersResults(results: Result<[Follower]>) {
        switch results {
        case .success(let followers):
            self.followers.append(contentsOf: followers)
            let followersPresentation = self.followers.map { FollowerPresentation(follower: $0) }
            notify(.loadFollowers(followersPresentation))
        case .failure(let error):
            notify(.requestError(error))
        }
    }
}

// MARK: - Follower Helper
extension FollowersViewModel {
    
    func isFollowersEmpty() -> Bool {
        if followers.count == 0 { return true }
        
        return false
    }
    
    func filterFollowersIfNeeded(isSearching: Bool,
                                 searchText: String?) {
        switch isSearching {
        case true:
            filteredFollowers = followers.filter { $0.login.lowercased().contains(searchText!.lowercased()) }
            notify(.filterableFollowers(filteredFollowers.map { FollowerPresentation(follower: $0) }))
        case false:
            filteredFollowers.removeAll()
            notify(.filterableFollowers(followers.map { FollowerPresentation(follower: $0) }))
        }
    }
}

// MARK: - Output Helper
extension FollowersViewModel {
    
    private func notify(_ output: FollowersViewModelOutput) {
        delegate?.handleOutput(output: output)
    }
}
