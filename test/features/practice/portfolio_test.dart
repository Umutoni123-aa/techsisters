import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:techsisters/features/practice/domain/entities/portfolio_project.dart';
import 'package:techsisters/features/practice/domain/entities/project_validator.dart';
import 'package:techsisters/features/practice/domain/repositories/portfolio_repository.dart';
import 'package:techsisters/features/practice/domain/usecases/portfolio_usecases.dart';
import 'package:techsisters/features/practice/presentation/bloc/portfolio_bloc.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  group('ProjectValidator', () {
    test('the title is required and must be long enough', () {
      expect(ProjectValidator.validateTitle(null), isNotNull);
      expect(ProjectValidator.validateTitle('   '), isNotNull);
      expect(ProjectValidator.validateTitle('ab'), isNotNull);
      expect(ProjectValidator.validateTitle('My site'), isNull);
    });

    test('the title cannot be longer than 60 letters', () {
      expect(ProjectValidator.validateTitle('a' * 61), isNotNull);
      expect(ProjectValidator.validateTitle('a' * 60), isNull);
    });

    test('the link is optional but must be a web address', () {
      expect(ProjectValidator.validateLink(''), isNull);
      expect(ProjectValidator.validateLink(null), isNull);
      expect(ProjectValidator.validateLink('https://example.com/me'), isNull);
      expect(ProjectValidator.validateLink('example'), isNotNull);
      expect(ProjectValidator.validateLink('ftp://example.com'), isNotNull);
    });
  });

  group('PortfolioBloc', () {
    late MockPortfolioRepository repository;
    late StreamController<List<PortfolioProject>> projectsStream;
    late PortfolioBloc bloc;

    final saved = PortfolioProject(
      id: 'p1',
      title: 'My site',
      description: 'A page about me',
      link: '',
      createdAt: DateTime(2026, 11, 20),
    );

    setUp(() {
      repository = MockPortfolioRepository();
      projectsStream = StreamController<List<PortfolioProject>>();
      when(() => repository.watchProjects('u1'))
          .thenAnswer((_) => projectsStream.stream);
      when(
        () => repository.addProject(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          link: any(named: 'link'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => repository.updateProject(
          userId: any(named: 'userId'),
          projectId: any(named: 'projectId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          link: any(named: 'link'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => repository.deleteProject(
          userId: any(named: 'userId'),
          projectId: any(named: 'projectId'),
        ),
      ).thenAnswer((_) async {});

      bloc = PortfolioBloc(
        userId: 'u1',
        watchProjects: WatchProjectsUseCase(repository),
        saveProject: SaveProjectUseCase(repository),
        deleteProject: DeleteProjectUseCase(repository),
      );
    });

    tearDown(() async {
      await bloc.close();
      // Not awaited: a stream nobody listened to never finishes closing.
      unawaited(projectsStream.close());
    });

    Future<void> send(PortfolioEvent event) async {
      bloc.add(event);
      await pumpEventQueue();
    }

    test('shows the projects that arrive from Firestore', () async {
      await send(const LoadPortfolioEvent());
      expect(bloc.state.status, PortfolioStatus.loading);

      projectsStream.add([saved]);
      await pumpEventQueue();

      expect(bloc.state.status, PortfolioStatus.loaded);
      expect(bloc.state.projects, [saved]);
    });

    test('an invalid title is rejected and nothing is saved', () async {
      await send(const LoadPortfolioEvent());
      await send(
        const SaveProjectEvent(title: 'ab', description: '', link: ''),
      );

      expect(bloc.state.notice, isNotNull);
      expect(bloc.state.savedCount, 0);
      verifyNever(
        () => repository.addProject(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          link: any(named: 'link'),
        ),
      );
    });

    test('a bad link is rejected', () async {
      await send(
        const SaveProjectEvent(
          title: 'My site',
          description: '',
          link: 'not a link',
        ),
      );

      expect(bloc.state.notice, isNotNull);
      expect(bloc.state.savedCount, 0);
    });

    test('a new project is added with trimmed text (create)', () async {
      await send(
        const SaveProjectEvent(
          title: '  My site  ',
          description: ' About me ',
          link: '',
        ),
      );

      expect(bloc.state.savedCount, 1);
      expect(bloc.state.notice, 'Project saved');
      verify(
        () => repository.addProject(
          userId: 'u1',
          title: 'My site',
          description: 'About me',
          link: '',
        ),
      ).called(1);
    });

    test('a project with an id is updated, not added (update)', () async {
      await send(
        const SaveProjectEvent(
          projectId: 'p1',
          title: 'My new site',
          description: '',
          link: 'https://example.com',
        ),
      );

      expect(bloc.state.savedCount, 1);
      verify(
        () => repository.updateProject(
          userId: 'u1',
          projectId: 'p1',
          title: 'My new site',
          description: '',
          link: 'https://example.com',
        ),
      ).called(1);
      verifyNever(
        () => repository.addProject(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          link: any(named: 'link'),
        ),
      );
    });

    test('deleting removes the project (delete)', () async {
      await send(const DeleteProjectEvent('p1'));

      expect(bloc.state.notice, 'Project deleted');
      verify(() => repository.deleteProject(userId: 'u1', projectId: 'p1'))
          .called(1);
    });

    test('a failed save shows an error and keeps the form open', () async {
      when(
        () => repository.addProject(
          userId: any(named: 'userId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          link: any(named: 'link'),
        ),
      ).thenThrow(Exception('offline'));

      await send(
        const SaveProjectEvent(title: 'My site', description: '', link: ''),
      );

      expect(bloc.state.savedCount, 0);
      expect(bloc.state.saving, isFalse);
      expect(bloc.state.notice, contains('Could not save'));
    });
  });
}
