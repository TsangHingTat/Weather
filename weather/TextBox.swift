//
//  TextBox.swift
//  weather
//
//  Created by HingTatTsang on 11/12/2022.
//

import SwiftUI

struct TextBox: View {
    @State var text1: String
    @Binding var text2: String
    @State var size2 = 35.0
    var showtextlater = ""
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(NSLocalizedString("\(text1)", comment: "\(text1)"))
                        .font(.system(size: 25))
                        .padding()
                    Spacer()
                }
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(text2)\(showtextlater)")
                        .font(.system(size: size2))
                        .padding()

                }
            }
        }
        .frame(width: 170, height: 170)
        .background(Color.black.opacity(0.05))
        .cornerRadius(25)
        .shadow(radius: 20)
        .padding(5)
        
    }
}

struct TextnBox: View {
    @State var dob = ""
    @Binding var deg: String
    var showtextlater = ""
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text("風向")
                            .font(.system(size: 20))
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.up")
                            .resizable()
                            .frame(width: 20,height: 70)
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(Double(dob) ?? 0))
                            .rotationEffect(.degrees(180))
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Spacer()
                        Text("N")
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("W")
                            .padding()
                        Spacer()
                        Text("E")
                            .padding()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("S")
                            .padding()
                        Spacer()
                    }
                }
            }
        }
        .frame(width: 170, height: 170)
        .background(Color.black.opacity(0.05))
        .cornerRadius(25)
        .shadow(radius: 20)
        .onChange(of: deg) { _ in
            getdatas()
        }
        .padding(5)
        
    }
    func getdatas() -> Void {
        dob = ""
        for i in deg {
            if i == "1" || i == "2" || i == "3" || i == "4" || i == "5" || i == "6" || i == "7" || i == "8" || i == "9" || i == "0" {
                dob = "\(dob)\(i)"
            }
        }
        
    }
}



