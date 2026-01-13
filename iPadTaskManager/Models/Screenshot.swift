import Foundation
import SwiftData

/// 截图记录
@Model
final class Screenshot {
    /// 文件路径（相对于 App 沙盒）
    var filePath: String

    /// 缩略图路径
    var thumbnailPath: String?

    /// 关联的任务会话
    @Relationship
    var session: TaskSession?

    /// 截图时间
    var capturedAt: Date

    /// 文件大小（字节）
    var fileSize: Int

    init(
        filePath: String,
        thumbnailPath: String? = nil,
        session: TaskSession? = nil,
        fileSize: Int = 0
    ) {
        self.filePath = filePath
        self.thumbnailPath = thumbnailPath
        self.session = session
        self.capturedAt = Date()
        self.fileSize = fileSize
    }

    /// 获取完整文件 URL
    var fileURL: URL? {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        return documentsPath?.appendingPathComponent(filePath)
    }
}
