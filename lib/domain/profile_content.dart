class ProfileVisual {
  const ProfileVisual({required this.id, required this.asset});

  final String id;
  final String asset;
}

const profileAvatars = <ProfileVisual>[
  ProfileVisual(
    id: 'avatar_1',
    asset: 'assets/Profile_and_frames/avatar 1.png',
  ),
  ProfileVisual(
    id: 'avatar_2',
    asset: 'assets/Profile_and_frames/avatar 2.png',
  ),
  ProfileVisual(
    id: 'avatar_3',
    asset: 'assets/Profile_and_frames/avatar 3.png',
  ),
  ProfileVisual(
    id: 'avatar_4',
    asset: 'assets/Profile_and_frames/avatar 4.png',
  ),
  ProfileVisual(
    id: 'avatar_5',
    asset: 'assets/Profile_and_frames/avatar 5.png',
  ),
];

const profileFrames = <ProfileVisual>[
  ProfileVisual(id: 'frame_1', asset: 'assets/Profile_and_frames/Frame1.png'),
  ProfileVisual(id: 'frame_2', asset: 'assets/Profile_and_frames/Frame2.png'),
  ProfileVisual(id: 'frame_3', asset: 'assets/Profile_and_frames/Frame3.png'),
  ProfileVisual(id: 'frame_4', asset: 'assets/Profile_and_frames/Frame4.png'),
  ProfileVisual(id: 'frame_5', asset: 'assets/Profile_and_frames/frame5.png'),
];

ProfileVisual _findVisual(List<ProfileVisual> values, String id) =>
    values.firstWhere((value) => value.id == id, orElse: () => values.first);

ProfileVisual profileAvatarById(String id) => _findVisual(profileAvatars, id);
ProfileVisual profileFrameById(String id) => _findVisual(profileFrames, id);
