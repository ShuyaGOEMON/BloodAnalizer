# BloodAnalyzer

## �T�v
BloodAnalyzer �� iPhone �̒��L�p�J�����ƃg�[�`�����p���Č����R���� RGB �g�`�����W���A���A���^�C����������� CSV �o�͂��s�� SwiftUI �A�v���P�[�V�����ł��B�A�v���̃G���g���|�C���g�� [`BloodAnalyzerApp`](BloodAnalyzer/BloodAnalyzerApp.swift:11) �ŁA���C����ʂƂ��� [`ContentView`](BloodAnalyzer/ContentView.swift:13) ��\�����܂��B

## ��ȓ���
- **���A���^�C���v�� UI**  
  �v����ԁA�J�E���g�_�E���A�v�����ʃi�r�Q�[�V�����A�ۑ��f�[�^�ꗗ�A�g�`�`�����̉�ʂŐ��䂷�钆�S�R���|�[�l���g�� [`ContentView`](BloodAnalyzer/ContentView.swift:13) �ł��B
- **60fps �J�����L���v�`���ƃg�[�`����**  
  �J�����̃Z�b�g�A�b�v�A�I���EISO �����A�t���[�����Ƃ̉摜�����A�v���������� CSV �ۑ���S�����W�b�N�� [`CameraView`](BloodAnalyzer/RGBGetdemo.swift:5) �� [`CameraViewController`](BloodAnalyzer/RGBGetdemo.swift:21) �ɏW�񂳂�Ă��܂��B
- **���A���^�C���g�`�`��**  
  �v������ RGB �l���`���[�g�\�������p�r���[�Ƃ��� [`RealTimeChartR`](BloodAnalyzer/ContentView.swift:258)�A[`RealTimeChartG`](BloodAnalyzer/ContentView.swift:310)�A[`RealTimeChartB`](BloodAnalyzer/ContentView.swift:362) ���������Ă��܂��B
- **�v����̌��ʉ�ʂƃf�[�^�{��**  
  �v���I����̈ē��� [`NextView`](BloodAnalyzer/ContentView.swift:215)�A�ۑ��ς� CSV �̎Q�Ɓ^�폜�^���L�� [`SavedFilesView`](BloodAnalyzer/ContentView.swift:415)�A[`DeleteFilesView`](BloodAnalyzer/ContentView.swift:560)�A[`ExportFilesView`](BloodAnalyzer/ContentView.swift:608) ���S�����܂��B
- **CSV �o�͂Ƌ��L**  
  �v���f�[�^�� [`saveColorDataToCSV()`](BloodAnalyzer/RGBGetdemo.swift:268) �� CSV ������A�h�L�������g�f�B���N�g���֕ۑ���A[`ExportFilesView`](BloodAnalyzer/ContentView.swift:608) ����V�F�A�V�[�g���N���ł��܂��B

## �t�@�C���\��
- [`BloodAnalyzer/BloodAnalyzerApp.swift`](BloodAnalyzer/BloodAnalyzerApp.swift) ? �A�v���P�[�V�����̃G���g���|�C���g����� `WindowGroup` �\���B
- [`BloodAnalyzer/ContentView.swift`](BloodAnalyzer/ContentView.swift) ? �v���t���[�AUI �J�ځA�`���[�g�\���A�ۑ��f�[�^�Ǘ����܂ރ��C���r���[�Q�B
- [`BloodAnalyzer/RGBGetdemo.swift`](BloodAnalyzer/RGBGetdemo.swift) ? AVFoundation �ɂ��J��������ARGB ��́ACSV �����o�����W�b�N�B
- [`BloodAnalyzer/Assets.xcassets`](BloodAnalyzer/Assets.xcassets/Contents.json) ? �w�i�摜�E�A�C�R���E�z�F�Ɏg�p����A�Z�b�g�J�^���O�B
- [`BloodAnalyzer/Preview Content`](BloodAnalyzer/Preview Content/Preview Assets.xcassets/Contents.json) ? SwiftUI �v���r���[�p�A�Z�b�g�B

## �r���h�Ǝ��s
1. ���|�W�g�����擾��A[`BloodAnalyzer.xcodeproj.zip`](BloodAnalyzer.xcodeproj.zip) ���𓀂��A�������ꂽ `.xcodeproj` �܂��� `.xcworkspace` �� Xcode �ŊJ���܂��B
2. �^�[�Q�b�g�f�o�C�X�Ƃ��ăg�[�`���ڂ̎��@ iPhone ��I�����Ă��������i�V�~�����[�^�ł̓J�����E�g�[�`�@�\�����p�ł��܂���j�B
3. �K�v�ɉ����� `Signing & Capabilities` �Ń`�[���ƃo���h�����ʎq��ݒ肵�A�r���h�E���s���܂��B
4. ����N�����̓J�����ƃt�H�g���C�u�����i���L�p�j�̃A�N�Z�X�������߂��邽�ߋ����Ă��������B

## �v���t���[
1. �z�[����ʂŁu�v���J�n�v�������ƃJ�E���g�_�E�����J�n����A[`startCountdown()`](BloodAnalyzer/ContentView.swift:155) ���v���������Ǘ����܂��B
2. �J�E���g�_�E��������A[`CameraView`](BloodAnalyzer/RGBGetdemo.swift:5) ���N�����A�v������ [`MeasureTime`](BloodAnalyzer/ContentView.swift:21) �܂ŘA������ RGB �f�[�^���擾���܂��B
3. �t���[���������� [`getAverageColorFromUIImage(_:)`](BloodAnalyzer/RGBGetdemo.swift:195) �����ϐF���Z�o���A�\���p�o�b�t�@�ɒǉ����܂��B
4. �v���I����� CSV ���ۑ��E��������A[`NextView`](BloodAnalyzer/ContentView.swift:215) ���t�@�C�����ƍČv��������񎦂��܂��B

## �ۑ��f�[�^�Ǘ�
- �[���̃h�L�������g�f�B���N�g���ɐ�������� CSV �� [`fetchSavedFiles()`](BloodAnalyzer/ContentView.swift:170) �ɂ���čŐV���֕��ёւ��ĕ\������܂��B
- �ʃt�@�C���̍폜�� [`deleteFile(fileName:)`](BloodAnalyzer/ContentView.swift:200)�A���L�� [`exportFile()`](BloodAnalyzer/ContentView.swift:653) ������s�ł��܂��B
- �ۑ��ς� CSV ���ēǂݍ��݂��A�O���t�\�����鏈���� [`readCSVFile(fileName:)`](BloodAnalyzer/ContentView.swift:488) �� [`ArrayChart`](BloodAnalyzer/ContentView.swift:531) ���S���܂��B

## ���C�Z���X
�{�v���W�F�N�g�� [`LICENSE`](LICENSE) �̏����ɏ]���܂��B