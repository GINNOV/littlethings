import { redirect } from "next/navigation";

export default function XBooksPage() {
  redirect("/bookmarks?source=x");
}
