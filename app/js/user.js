import { v4 } from 'node-uuid';

const userIdKey = 'user_id';

export function getUserId () {
    if (!localStorage.getItem(userIdKey)) {
        localStorage.setItem(userIdKey, v4());
    }

    return Promise.resolve(localStorage.getItem(userIdKey));
}

export function userBridge (elmUser) {
    elmUser.getUserId.subscribe(() => {
        getUserId()
            .then((userId) => elmUser.userId.send(userId));
    });
}
