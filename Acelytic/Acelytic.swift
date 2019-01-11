//
//  Acelytic.swift
//  Acelytic
//
//  Created by AlexeyPanyok on 1/9/19.
//  Copyright © 2019 ACE. All rights reserved.
//

import RxSwift
import ObjectMapper

public class Acelytic {

    public static let shared = Acelytic()

    private lazy var repository: EventRepository = {
        EventRepository()
    }()

    private var deviceInfo = DeviceInfo()

    private var isInit = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func initialize(_ key: String) {
        RemoteApiService.shared.apiKey = key
        isInit = true
    }

    public func enableLocationTracking() {
        if (!isInit) {
            return
        }
        deviceInfo.startUpdateLocation()
    }

    public func enableForegroundTracking() {
        if (!isInit) {
            return
        }
        logEvent(C.START_SESSION)
        observe()
    }


    public func logEvent(_ name: String, params: [String: String] = [:]) {
        if (!isInit) {
            return
        }
        let _ = fullLogEvent(name, params)
                .subscribe(onNext: { (Response
                ) in
                    print(Response)
                }, onError: { (Error) in
                    print(Error)
                }) {

                }
    }

    public func setUserId(_ userId: String) {
        if(!isInit){
            return
        }
        UserDefaults.standard.set(userId, forKey: C.ACE_USER_ID_DEFAULTS)
    }

    public func clearUserId() {
        if(!isInit){
            return
        }
        UserDefaults.standard.set(nil, forKey: C.ACE_USER_ID_DEFAULTS)
    }

    private func internalLogEvent(_ event: EventModel) -> Observable<Response> {
        return repository.logEvent(event: event)
                .observeOn(MainScheduler.instance)
    }


    private func fullLogEvent(_ name: String, _ params: [String: String] = [:]) -> Observable<Response> {
        return Observable.just(EventModel(name: name, properties: params))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .map { event in
                    Mapper<DeviceInfo>().toJSON(self.deviceInfo).forEach { e in
                        event.properties[e.key] = e.value as? String
                    }
                    event.properties[C.ACE_USER_ID] = UserDefaults.standard.string(forKey: C.ACE_USER_ID_DEFAULTS) ?? ""
                    return event
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { event in
                    print(event.properties)
                })
                .flatMap { event in
                    self.internalLogEvent(event)
                }
    }

    private func observe() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(startSession),
                name: UIApplication.willEnterForegroundNotification,
                object: nil)

        NotificationCenter.default.addObserver(self,
                selector: #selector(endSession),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil)
    }

    @objc private func startSession() {
        logEvent(C.START_SESSION)
    }

    @objc private func endSession() {
        logEvent(C.END_SESSION)
    }

}
