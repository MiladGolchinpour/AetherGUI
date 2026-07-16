import SwiftUI

struct HeaderBar: View {
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [Color.aetherAccent, Color.aetherPurple],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 30, height: 30)
                Image(systemName: "shield.checkered")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("AETHER")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.aetherText)
                    .tracking(1)
                Text("Cloudflare WARP Proxy")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color.aetherTextDim)
            }
            Spacer()
        }
    }
}
