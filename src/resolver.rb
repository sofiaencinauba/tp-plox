class Resolver:
    def __init__(self, interpreter):
        self.interpreter = interpreter
        self.scopes = []

    def begin_scope(self):
    self.scopes.append({})

    def end_scope(self):
        self.scopes.pop()

    def declare(self, name):
        if not self.scopes:
            return

        self.scopes[-1][name.lexeme] = False

    def define(self, name):
        if not self.scopes:
            return

        self.scopes[-1][name.lexeme] = True