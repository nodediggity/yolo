//
//  CommentSnapshotTests.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import XCTest
import Yolo

class CommentSnapshotTests: XCTestCase {
    
    func test_comment_with_single_line() {
        let sut = makeSUT()
        sut.display(makeSingleComment())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "COMMENT_WITH_SINGLE_LINE_light")
    }
    
    func test_comment_with_multi_line_line() {
        let sut = makeSUT()
        sut.display(makeMultiLineComment())
        
        assert(snapshot: sut.snapshot(for: .iPhone12(style: .light)), named: "COMMENT_WITH_MULTIPLE_LINES_light")
    }
}

private extension CommentSnapshotTests {
    func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.configure = { tableView in
            tableView.register(CommentView.self)
        }
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    func makeSingleComment() -> [CommentStub] {
        return [
            CommentStub(
                Comment(
                    id: "any",
                    text: "this is a single line comment",
                    user: .init(id: "any", name: "Any Name", imageURL: makeURL())
                )
            )
        ]
    }
    
    func makeMultiLineComment() -> [CommentStub] {
        return [
            CommentStub(
                Comment(
                    id: "any",
                    text: "this is a multi-line comment that is on more than one line, it doesn't really lead anywhere but it pads out the comment text",
                    user: .init(id: "any", name: "Any Name", imageURL: makeURL())
                )
            )
        ]
    }
    
}

private extension ListViewController {
    func display(_ stubs: [CommentStub]) {
        let cells: [CellController] = stubs.map { stub in
            let controller = CommentCellController(model: stub.viewModel)
            stub.controller = controller
            return .init(controller)
        }
        
        display(cells)
    }
}

private final class CommentStub {
    let viewModel: CommentViewModel
    weak var controller: CommentCellController?
    
    private var image: UIImage?
    
    init(_ item: Comment, image: UIImage? = nil) {
        self.viewModel = CommentPresenter.map(item)
        self.image = image
    }
}
