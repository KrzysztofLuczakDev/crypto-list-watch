//
//  HelpSupportViews.swift
//  crypto-list Watch App
//
//  Created by Krzysztof Łuczak on 01/06/2025.
//

import SwiftUI
import WatchKit

// MARK: - FAQ View
struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let faqItems = [
        FAQItem(
            question: "How often does the data update?",
            answer: "Data updates based on your refresh interval setting. You can set it from 10 seconds to manual refresh."
        ),
        FAQItem(
            question: "How do I add coins to my watchlist?",
            answer: "Tap the star icon next to any cryptocurrency to add it to your favorites/watchlist."
        ),
        FAQItem(
            question: "Can I change the currency?",
            answer: "Yes! Go to Settings > Currency to choose between USD, EUR, BTC, or ETH."
        ),
        FAQItem(
            question: "Why is the app not updating?",
            answer: "Check your internet connection and refresh interval settings. Manual refresh requires pulling down on the list."
        ),
        FAQItem(
            question: "How do I sort my watchlist?",
            answer: "Go to Settings > Watchlist Settings > Sorting to choose how your favorites are ordered."
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(faqItems, id: \.question) { item in
                    FAQItemView(item: item)
                }
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItem {
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.1))
        )
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Contact Info
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text("Get in Touch")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                        
                        Text("We're here to help! Reach out to us through any of the following methods:")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Contact Methods
                    VStack(spacing: 8) {
                        ContactMethodRow(
                            icon: "envelope",
                            title: "Email Support",
                            subtitle: "support@cryptolist.app",
                            action: {
                                sendEmail()
                            }
                        )
                        
                        ContactMethodRow(
                            icon: "globe",
                            title: "Website",
                            subtitle: "Visit our support page",
                            action: {
                                openWebsite()
                            }
                        )
                        
                        ContactMethodRow(
                            icon: "questionmark.circle",
                            title: "Help Center",
                            subtitle: "Browse our knowledge base",
                            action: {
                                openHelpCenter()
                            }
                        )
                    }
                    
                    // Response Time
                    VStack(spacing: 4) {
                        Text("Response Time")
                            .font(.system(size: 10))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("We typically respond within 24 hours")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 12)
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Contact Support", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func sendEmail() {
        let email = "support@cryptolist.app"
        let subject = "Crypto List Support Request"
        let body = """
        
        
        ---
        App Version: 1.0.0
        Device: Apple Watch
        watchOS Version: \(WKInterfaceDevice.current().systemVersion)
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            WKExtension.shared().openSystemURL(url)
            dismiss()
        } else {
            alertMessage = "Please email us at: \(email)"
            showingAlert = true
        }
    }
    
    private func openWebsite() {
        alertMessage = "Visit our website at: cryptolist.app/support"
        showingAlert = true
    }
    
    private func openHelpCenter() {
        alertMessage = "Visit our help center at: help.cryptolist.app"
        showingAlert = true
    }
}

struct ContactMethodRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                    .frame(width: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Report Bug View
struct ReportBugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "ladybug.circle.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Report a Bug")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Help us improve the app by reporting any issues you encounter.")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Bug Report Options
                VStack(spacing: 8) {
                    BugReportOptionRow(
                        icon: "envelope",
                        title: "Email Bug Report",
                        subtitle: "Send detailed bug report via email",
                        action: {
                            sendBugReportEmail()
                        }
                    )
                    
                    BugReportOptionRow(
                        icon: "exclamationmark.triangle",
                        title: "Quick Report",
                        subtitle: "Report common issues quickly",
                        action: {
                            showQuickReport()
                        }
                    )
                    
                    BugReportOptionRow(
                        icon: "doc.text",
                        title: "Crash Report",
                        subtitle: "Report app crashes or freezes",
                        action: {
                            sendCrashReport()
                        }
                    )
                }
                
                // Auto-collected Info
                VStack(spacing: 4) {
                    Text("Automatically Included")
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("• App version: 1.0.0\n• watchOS version: \(WKInterfaceDevice.current().systemVersion)\n• Device model: Apple Watch\n• Timestamp")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Report Bug")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Bug Report", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func sendBugReportEmail() {
        let email = "bugs@cryptolist.app"
        let subject = "Bug Report - Crypto List"
        let body = """
        Please describe the bug you encountered:
        
        Steps to reproduce:
        1. 
        2. 
        3. 
        
        Expected behavior:
        
        
        Actual behavior:
        
        
        ---
        Technical Information:
        App Version: 1.0.0
        Device: Apple Watch
        watchOS Version: \(WKInterfaceDevice.current().systemVersion)
        Timestamp: \(Date())
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            WKExtension.shared().openSystemURL(url)
            dismiss()
        } else {
            alertMessage = "Please email us at: \(email)"
            showingAlert = true
        }
    }
    
    private func showQuickReport() {
        alertMessage = "For quick reports, please email: bugs@cryptolist.app with a brief description of the issue."
        showingAlert = true
    }
    
    private func sendCrashReport() {
        let email = "crashes@cryptolist.app"
        let subject = "Crash Report - Crypto List"
        let body = """
        Crash Report
        
        When did the crash occur?
        
        
        What were you doing when it crashed?
        
        
        ---
        Technical Information:
        App Version: 1.0.0
        Device: Apple Watch
        watchOS Version: \(WKInterfaceDevice.current().systemVersion)
        Timestamp: \(Date())
        """
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            WKExtension.shared().openSystemURL(url)
            dismiss()
        } else {
            alertMessage = "Please email us at: \(email)"
            showingAlert = true
        }
    }
}

struct BugReportOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                    .frame(width: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Terms & Privacy View
struct TermsPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.circle.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Legal Information")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                // Legal Documents
                VStack(spacing: 8) {
                    LegalDocumentRow(
                        icon: "doc.text",
                        title: "Terms of Service",
                        subtitle: "Last updated: June 1, 2025",
                        action: {
                            // Open Terms of Service
                        }
                    )
                    
                    LegalDocumentRow(
                        icon: "hand.raised",
                        title: "Privacy Policy",
                        subtitle: "Last updated: June 1, 2025",
                        action: {
                            // Open Privacy Policy
                        }
                    )
                    
                    LegalDocumentRow(
                        icon: "building.2",
                        title: "Third-Party Licenses",
                        subtitle: "Open source components",
                        action: {
                            // Open Third-Party Licenses
                        }
                    )
                }
                
                // Privacy Summary
                VStack(spacing: 8) {
                    Text("Privacy Summary")
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("• We don't collect personal data\n• All settings stored locally\n• No tracking or analytics\n• Data from CoinLore API only")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 12)
        }
        .navigationTitle("Terms & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LegalDocumentRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                    .frame(width: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 