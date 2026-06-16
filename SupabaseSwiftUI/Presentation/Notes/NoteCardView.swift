//
//  NoteCardView.swift
//  SupabaseSwiftUI
//

import SwiftUI
import Kingfisher

struct NoteCardView: View {
    let note: Note
    let imageURL: URL?
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageURL {
                KFImage(imageURL)
                    .resizable()
                    .placeholder {
                        AppColors.surfaceLighter
                    }
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(note.title)
                        .font(AppFonts.titleMedium)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.errorMain)
                    }
                    .buttonStyle(.plain)
                }

                if !note.content.isEmpty {
                    Text(note.content)
                        .font(AppFonts.bodyMedium)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(note.updatedDateShort)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textMuted)
                    .padding(.top, 2)
            }
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.surfaceDark)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
