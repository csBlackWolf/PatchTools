import unittest
from issue_addon_prefix import addon_from_body, prefixed_title


class AddonPrefixTests(unittest.TestCase):
    def test_form_selection_and_changed_selection(self):
        body = "### Addon / Modul\n\nPatchToolsMaps\n\n### Your idea / Deine Idee\n\nText"
        self.assertEqual(addon_from_body(body), "PatchToolsMaps")
        self.assertEqual(prefixed_title("[PT] [Bug]: Map", addon_from_body(body)), "[PTM] [Bug]: Map")
        self.assertEqual(prefixed_title("[PTB] Bag", "PatchToolsBags"), "[PTB] Bag")

    def test_preserve_title_without_valid_selection(self):
        for body in [None, "### Addon / Modul\n\nUnknown", "### Addon / Modul\n\nPatchTools\n\n### Addon / Modul\n\nPatchToolsBags"]:
            self.assertIsNone(addon_from_body(body))
            self.assertEqual(prefixed_title("[Idea]: unchanged", addon_from_body(body)), "[Idea]: unchanged")

    def test_code_examples_do_not_select_addon(self):
        self.assertIsNone(addon_from_body("```\n### Addon / Modul\n\nPatchToolsBags\n```"))

    def test_duplicate_prefixes_and_issue_type(self):
        self.assertEqual(prefixed_title("[PT] [PTM] [Translation]: Wording", "PatchToolsBags"), "[PTB] [Translation]: Wording")
        self.assertEqual(prefixed_title("[Bug]: mention [PTM] in text", "PatchTools"), "[PT] [Bug]: mention [PTM] in text")


if __name__ == "__main__":
    unittest.main()
